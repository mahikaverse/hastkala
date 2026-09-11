import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../models/product_model.dart';
import 'adaptive_product_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlistTap,
    this.isWished = false,
  });

  final Product product;
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
                      child: AdaptiveProductImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.handyman_outlined, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                              const SizedBox(height: 4),
                              Text(product.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (product.oldPrice != null)
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
                          '${((1 - product.price / product.oldPrice!) * 100).round()}% OFF',
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
                      Icon(Icons.star, size: 14, color: AppColors.mustardGold),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.mustardGold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviews})',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '\u20B9${product.price}',
                        style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '\u20B9${product.oldPrice}',
                          style: AppTextStyles.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    product.artisan,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
