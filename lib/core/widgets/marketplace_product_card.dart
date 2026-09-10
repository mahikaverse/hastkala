import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../models/marketplace_product.dart';

class MarketplaceProductCard extends StatelessWidget {
  const MarketplaceProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlistTap,
    this.isWished = false,
  });

  final MarketplaceProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final bool isWished;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.warmBeige,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radiusMD),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radiusMD),
                      ),
                      child: product.imageUrls.isNotEmpty
                          ? Image.asset(
                              product.imageUrls.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.terracotta,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(
                          '${product.discountPercent.round()}% OFF',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.cream, fontSize: 10),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onWishlistTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                          ],
                        ),
                        child: Icon(
                          isWished ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isWished ? AppColors.terracotta : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.mustardGold),
                      const SizedBox(width: 2),
                      Text(
                        product.averageRating.toStringAsFixed(1),
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.mustardGold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.totalReviews})',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '\u20B9${product.effectivePrice.toStringAsFixed(0)}',
                        style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          '\u20B9${product.price.toStringAsFixed(0)}',
                          style: AppTextStyles.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 11,
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

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.handyman_outlined, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 4),
          Text(product.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
