import 'package:flutter/material.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/models/property_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;
  final bool showHostInfo;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.showHostInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: property.hasPhotos
                    ? CachedNetworkImage(
                        imageUrl: property.mainPhoto!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.backgroundGrey,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.backgroundGrey,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppColors.textLight,
                            size: 48,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.backgroundGrey,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppColors.textLight,
                          size: 48,
                        ),
                      ),
              ),
            ),
            
            // Property Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPropertyTypeColor(property.propertyType),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          property.propertyTypeDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.locationDisplay,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Property Details
                  Row(
                    children: [
                      _buildPropertyDetail(
                        Icons.bed,
                        '${property.bedrooms}',
                        AppColors.textSecondary,
                      ),
                      const SizedBox(width: 16),
                      _buildPropertyDetail(
                        Icons.bathtub_outlined,
                        '${property.bathrooms}',
                        AppColors.textSecondary,
                      ),
                      const SizedBox(width: 16),
                      _buildPropertyDetail(
                        Icons.people,
                        '${property.maxGuests}',
                        AppColors.textSecondary,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Price and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.displayPrice,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                      if (property.rating > 0) ...[
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.ratingStar,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          property.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${property.reviewCount})',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetail(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getPropertyTypeColor(String propertyType) {
    switch (propertyType) {
      case 'apartment':
        return AppColors.apartment;
      case 'villa':
        return AppColors.villa;
      case 'riad':
        return AppColors.riad;
      case 'studio':
        return AppColors.studio;
      default:
        return AppColors.primaryRed;
    }
  }
}