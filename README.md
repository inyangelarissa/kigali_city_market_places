#  Kigali Directory

A Flutter-based mobile application for discovering and navigating businesses, services, and places across Kigali, Rwanda. Built with Firebase as the backend and Riverpod for reactive state management.

---

## Features

### Authentication
- Email and password registration and login via Firebase Authentication
- Persistent login sessions across app restarts using Firebase's built-in token persistence
- Auth-aware routing through `AuthWrapper` — unauthenticated users are redirected to the login screen automatically

### Category Browsing
- Browse places and businesses across predefined categories: **Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction, Hotel, Bank, Pharmacy, Shopping Mall, School**, and more
- Filter the directory in real time by selecting a category chip on the home screen
- "All" filter shows the complete listings across every category

###  Search
- Full-text search bar for finding places and businesses by name or keyword
- Search results update reactively as the user types

### Listings
- View detailed information for each listing including name, category, description, and location
- Each listing card links to external resources (website, phone, directions) via `url_launcher`

### My Listings
- Authenticated users can create, edit, and delete their own listings
- Listings are scoped to the owner's UID, ensuring users can only manage their own content

### Map View
- Interactive map powered by `flutter_map` (OpenStreetMap tiles) and `latlong2`
- View all listed places as map markers
- Device location detection via `geolocator` to center the map on the user's current position

### Dark Mode
- Full light and dark theme support using a custom `AppTheme`
- Theme preference persisted across sessions using `shared_preferences`
- Toggle available in the Settings tab

---

## Firestore Database Structure

The app uses Cloud Firestore with the following top-level collections:

```
firestore-root/
│
├── users/
│   └── {userId}/                        # Document ID = Firebase Auth UID
│       ├── email:        string
│       ├── displayName:  string
│       └── createdAt:    timestamp
│
└── listings/
    └── {listingId}/                     # Auto-generated document ID
        ├── name:         string
        ├── category:     string          # e.g. "Restaurant", "Hospital"
        ├── description:  string
        ├── address:      string
        ├── latitude:     number
        ├── longitude:    number
        ├── phone:        string
        ├── website:      string
        ├── ownerId:      string          # Firebase Auth UID of the creator
        └── createdAt:    timestamp
```

### Security Rules

Access to Firestore is governed by server-side Security Rules:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Listings — readable by any authenticated user
    // Writable only by the listing's owner
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
                            && request.auth.uid == resource.data.ownerId;
    }

    // User profiles — accessible only by the profile owner
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

---

## State Management — Riverpod

The app uses **Flutter Riverpod (v2)** for all state management. The entire widget tree is wrapped in a `ProviderScope` in `main.dart`, making all providers available globally.

### Key Providers

| Provider | Type | Responsibility |
|---|---|---|
| `themeModeProvider` | `StateProvider<ThemeMode>` | Tracks and updates the current light/dark theme mode |
| `authStateProvider` | `StreamProvider<User?>` | Listens to Firebase Auth state changes; drives `AuthWrapper` routing |
| `listingsProvider` | `StreamProvider<List<Listing>>` | Streams all listings from Firestore in real time |
| `categoryFilterProvider` | `StateProvider<String>` | Holds the currently selected category filter (default: `"All"`) |
| `filteredListingsProvider` | `Provider<List<Listing>>` | Derived provider — filters `listingsProvider` by `categoryFilterProvider` |
| `userListingsProvider` | `StreamProvider<List<Listing>>` | Streams only the listings owned by the currently authenticated user |

### How It Works

The app favors **`ConsumerWidget`** and **`ConsumerStatefulWidget`** over plain Flutter widgets, allowing any widget to `ref.watch()` a provider and rebuild automatically when state changes.

```dart
// Example: Home screen reactively watching filtered listings
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(filteredListingsProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);

    return listings.when(
      data: (data) => ListingsGrid(listings: data),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => ErrorView(message: e.toString()),
    );
  }
}
```

```dart
// Example: Updating the category filter from a chip
ref.read(categoryFilterProvider.notifier).state = "Restaurant";
```

Firestore streams are consumed via `StreamProvider`, so any change in the database is automatically reflected in the UI without manual refresh logic.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 (Dart ≥ 3.0) |
| Backend | Firebase (Auth + Firestore) |
| State Management | Flutter Riverpod v2 |
| Maps | flutter_map + OpenStreetMap |
| Geolocation | geolocator |
| Fonts | google_fonts |
| Theme Persistence | shared_preferences |
| External Links | url_launcher |

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- A Firebase project with **Authentication** (Email/Password) and **Firestore** enabled
- FlutterFire CLI configured

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/your-username/kigali-directory.git
cd kigali-directory

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
flutterfire configure

# 4. Run the app
flutter run
```

>  Make sure your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are placed in the correct directories after running `flutterfire configure`.

---

## Project Structure

```
lib/
├── main.dart                  # App entry point, ProviderScope, Firebase init
├── firebase_options.dart      # Auto-generated FlutterFire config
├── theme/
│   ├── app_theme.dart         # Light and dark ThemeData definitions
│   └── theme_provider.dart    # Riverpod provider for ThemeMode
├── models/
│   └── listing.dart           # Listing data model + Firestore serialization
├── providers/
│   ├── auth_provider.dart     # Auth state stream provider
│   └── listings_provider.dart # Listings stream + filter providers
├── views/
│   ├── auth_wrapper.dart      # Routes between auth and main app
│   ├── home_screen.dart       # Category browser + listings grid
│   ├── map_screen.dart        # flutter_map integration
│   ├── my_listings_screen.dart# User's own listings
│   └── settings_screen.dart   # Theme toggle + account settings
└── widgets/
    ├── listing_card.dart      # Reusable listing card widget
    └── category_chips.dart    # Category filter chip row
```

---

## License

This project is licensed under the MIT License. See `LICENSE` for details.
