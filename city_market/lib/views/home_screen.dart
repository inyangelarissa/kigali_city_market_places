import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:city_market/models/listing.dart';
import 'package:city_market/services/listing_service.dart';
import 'package:city_market/theme/app_theme.dart';
import 'package:city_market/views/create_listing_screen.dart';
import 'package:city_market/views/listing_detail_screen.dart';
import 'package:city_market/widgets/listing_card.dart';
import 'package:google_fonts/google_fonts.dart';

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for selected category filter
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Filtered listings provider
final filteredListingsProvider = Provider<AsyncValue<List<Listing>>>((ref) {
  final listings = ref.watch(listingsProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final categoryFilter = ref.watch(categoryFilterProvider);

  return listings.whenData((listingsList) {
    return listingsList.where((listing) {
      final matchesSearch = searchQuery.isEmpty ||
          listing.name.toLowerCase().contains(searchQuery) ||
          listing.description.toLowerCase().contains(searchQuery);
      final matchesCategory = categoryFilter == null ||
          categoryFilter == 'All' ||
          listing.category == categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();
  });
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
    'Hotel',
    'Bank',
    'Pharmacy',
    'Shopping Mall',
    'School',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredListings = ref.watch(filteredListingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryCyan.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_city_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kigali Directory',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryNavy,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Discover your city',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNavy,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryNavy.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const CreateListingScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Search Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search places, businesses...',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: 15,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.search_rounded,
                            color: AppTheme.primaryCyan,
                            size: 24,
                          ),
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Categories
                  Text(
                    'Browse Categories',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Enhanced Category Chips
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                  ref.read(categoryFilterProvider.notifier).state = 
                                      category == 'All' ? null : category;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AppTheme.primaryNavy,
                              checkmarkColor: Colors.white,
                              elevation: isSelected ? 4 : 0,
                              shadowColor: AppTheme.primaryNavy.withOpacity(0.3),
                              labelStyle: GoogleFonts.inter(
                                color: isSelected 
                                    ? Colors.white 
                                    : Colors.grey[700],
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 13,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected 
                                      ? AppTheme.primaryNavy 
                                      : Colors.grey.shade300,
                                  width: isSelected ? 0 : 1,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Listings Grid
          filteredListings.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            data: (listings) {
              if (listings.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No places found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CreateListingScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Place'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final listing = listings[index];
                      return ListingCard(
                        listing: listing,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ListingDetailScreen(listing: listing),
                            ),
                          );
                        },
                      );
                    },
                    childCount: listings.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
