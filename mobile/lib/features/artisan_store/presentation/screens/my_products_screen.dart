import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/widgets/adaptive_product_image.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final DataService _data = DataService();
  String _selectedFilter = 'All';

  ArtisanStore? get _store =>
      _data.stores.isNotEmpty ? _data.stores.first : null;

  List<MarketplaceProduct> get _myProducts {
    if (_store == null) return [];
    final all = _data.getProductsByStore(_store!.id);
    if (_selectedFilter == 'All') return all;
    if (_selectedFilter == 'Published') return all.where((p) => p.isPublished).toList();
    if (_selectedFilter == 'Draft') return all.where((p) => !p.isPublished).toList();
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final products = _myProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        title: Text('My Products', style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            onPressed: () => Navigator.pushNamed(context, '/voice-add-product'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: products.isEmpty
                ? _buildEmptyState()
                : _buildProductGrid(products),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Published', 'Draft'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
      color: AppColors.surface,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f, style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.charcoal,
              )),
              selected: isSelected,
              selectedColor: AppColors.terracotta,
              backgroundColor: AppColors.warmBeige.withValues(alpha: 0.5),
              side: BorderSide.none,
              onSelected: (_) => setState(() => _selectedFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: AppDimensions.lg),
            Text('No products yet', style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal)),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Add your first product and start reaching more customers.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xl),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/voice-add-product'),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<MarketplaceProduct> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(MarketplaceProduct product) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/seller-product-detail',
          arguments: {'productId': product.id},
        );
        if (result == true) setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
                    child: SizedBox(
                      width: double.infinity,
                      child: AdaptiveProductImage(
                        imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (!product.isPublished)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Draft', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.charcoal),
                      ),
                      onSelected: (v) async {
                        if (v == 'edit') {
                          final result = await Navigator.pushNamed(
                            context,
                            '/seller-product-detail',
                            arguments: {'productId': product.id},
                          );
                          if (result == true) setState(() {});
                        } else if (v == 'share') {
                          Navigator.pushNamed(context, '/share-everywhere', arguments: product.id);
                        } else if (v == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text('Delete Product'),
                              content: const Text('This action cannot be undone.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            _data.deleteProduct(product.id);
                            setState(() {});
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Product deleted'), backgroundColor: AppColors.error),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'share', child: Text('📣 Share Everywhere')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.effectivePrice.toInt()}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: product.stockQuantity > 0 ? AppColors.oliveGreen : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.stockQuantity > 0
                              ? 'In Stock (${product.stockQuantity})'
                              : 'Out of Stock',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: product.stockQuantity > 0 ? AppColors.oliveGreen : AppColors.error,
                            fontSize: 11,
                          ),
                        ),
                      ),
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
}
