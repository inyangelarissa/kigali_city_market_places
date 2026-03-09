import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:city_market/models/listing.dart';
import 'package:city_market/theme/app_theme.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'police station':
        return Icons.local_police_rounded;
      case 'library':
        return Icons.local_library_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'café':
      case 'cafe':
        return Icons.local_cafe_rounded;
      case 'park':
        return Icons.park_rounded;
      case 'tourist attraction':
        return Icons.attractions_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'pharmacy':
        return Icons.local_pharmacy_rounded;
      case 'shopping mall':
        return Icons.shopping_bag_rounded;
      case 'school':
        return Icons.school_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hospital':
        return const Color(0xFFEF4444);
      case 'police station':
        return const Color(0xFF3B82F6);
      case 'library':
        return const Color(0xFF8B5CF6);
      case 'restaurant':
        return const Color(0xFFF59E0B);
      case 'café':
      case 'cafe':
        return const Color(0xFF92400E);
      case 'park':
        return const Color(0xFF10B981);
      case 'tourist attraction':
        return const Color(0xFFEC4899);
      case 'hotel':
        return const Color(0xFF6366F1);
      case 'bank':
        return const Color(0xFF059669);
      case 'pharmacy':
        return const Color(0xFF14B8A6);
      case 'shopping mall':
        return const Color(0xFFF43F5E);
      case 'school':
        return const Color(0xFF2563EB);
      default:
        return AppTheme.primaryCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(listing.category);
    
    return Hero(
      tag: 'listing_${listing.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with gradient and icon
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -10,
                        bottom: -10,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      // Icon
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIcon(listing.category),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: categoryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            listing.category,
                            style: GoogleFonts.inter(
                              color: categoryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Name
                        Text(
                          listing.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        
                        // Location info
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                listing.address,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
