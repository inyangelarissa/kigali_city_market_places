// lib/screens/map/map_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/listing_provider.dart';
import '../../models/listing_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../listings/listing_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  ListingModel? _selectedListing;
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<ListingModel> listings) {
    return listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: listing.category,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _categoryHue(listing.category),
        ),
        onTap: () => setState(() => _selectedListing = listing),
      );
    }).toSet();
  }

  double _categoryHue(String category) {
    switch (category) {
      case 'Hospitals':
        return BitmapDescriptor.hueRed;
      case 'Cafés':
      case 'Restaurants':
        return BitmapDescriptor.hueOrange;
      case 'Parks':
        return BitmapDescriptor.hueGreen;
      case 'Tourist Attractions':
        return BitmapDescriptor.hueViolet;
      case 'Libraries':
        return BitmapDescriptor.hueCyan;
      case 'Police Stations':
        return BitmapDescriptor.hueBlue;
      default:
        return BitmapDescriptor.hueYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Consumer<ListingProvider>(
        builder: (context, provider, _) {
          final listings = _selectedCategory == 'All'
              ? provider.allListings
              : provider.allListings
                  .where((l) => l.category == _selectedCategory)
                  .toList();

          return Stack(
            children: [
              // Map
              GoogleMap(
                onMapCreated: (controller) => _mapController = controller,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                      AppConstants.kigaliLat, AppConstants.kigaliLng),
                  zoom: 13,
                ),
                markers: _buildMarkers(listings),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                onTap: (_) => setState(() => _selectedListing = null),
              ),
              // Top bar
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark.withValues(alpha:0.92),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.map_rounded,
                              color: AppTheme.accentOrange, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Map View',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentOrange.withValues(alpha:0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${listings.length} places',
                              style: const TextStyle(
                                color: AppTheme.accentOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Category filter chips
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: AppConstants.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = AppConstants.categories[i];
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accentBlue
                                    : AppTheme.primaryDark.withValues(alpha:0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.accentBlue
                                      : AppTheme.dividerColor,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Selected listing card
              if (_selectedListing != null)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: _buildListingPreviewCard(_selectedListing!),
                ),
              // My location FAB
              Positioned(
                bottom: _selectedListing != null ? 168 : 24,
                right: 16,
                child: FloatingActionButton.small(
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        const CameraPosition(
                          target: LatLng(
                              AppConstants.kigaliLat, AppConstants.kigaliLng),
                          zoom: 13,
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppTheme.cardDark,
                  child: const Icon(Icons.my_location_rounded,
                      color: AppTheme.textPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListingPreviewCard(ListingModel listing) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ListingDetailScreen(listing: listing)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryDark.withValues(alpha:0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  AppConstants.categoryIcons[listing.category] ?? '📍',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppTheme.starYellow, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        listing.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: AppTheme.starYellow, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        listing.category,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}