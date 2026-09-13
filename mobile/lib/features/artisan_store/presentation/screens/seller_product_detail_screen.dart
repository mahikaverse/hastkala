import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/widgets/adaptive_product_image.dart';

class SellerProductDetailScreen extends StatefulWidget {
  final String productId;
  const SellerProductDetailScreen({super.key, required this.productId});

  @override
  State<SellerProductDetailScreen> createState() => _SellerProductDetailScreenState();
}

class _SellerProductDetailScreenState extends State<SellerProductDetailScreen> {
  final DataService _data = DataService();
  final ImagePicker _picker = ImagePicker();

  MarketplaceProduct? get _product => _data.getProduct(widget.productId);

  void _refresh() => setState(() {});

  Future<void> _changeImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Change Product Image', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.terracotta),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.terracotta),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      final confirmed = await Navigator.pushNamed(
        context,
        '/edit-product',
        arguments: {'productId': widget.productId, 'newImagePath': picked.path},
      );
      if (confirmed == true) _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.pushNamed(
      context,
      '/edit-product',
      arguments: {'productId': widget.productId},
    );
    if (result == true) _refresh();
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
        title: const Text('Delete Product'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _data.deleteProduct(widget.productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted'), backgroundColor: AppColors.error),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.brown,
          foregroundColor: AppColors.cream,
          title: Text('Product Details', style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
        ),
        body: const Center(child: Text('Product not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        title: Text('Product Details', style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 20),
            onPressed: _navigateToEdit,
            tooltip: 'Edit Product',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(product),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(product),
                  const SizedBox(height: AppDimensions.sm),
                  Text(product.name, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('₹${product.effectivePrice.toInt()}', style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.brown, fontWeight: FontWeight.bold,
                  )),
                  if (product.hasDiscount) ...[
                    const SizedBox(height: 2),
                    Text('Was ₹${product.price.toInt()} (${product.discountPercent.toStringAsFixed(0)}% off)',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: AppDimensions.md),
                  _buildDetailGrid(product),
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.lg),
                    _buildSectionTitle('Description'),
                    const SizedBox(height: AppDimensions.sm),
                    Text(product.description, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
                  ],
                  if (product.tags.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.lg),
                    _buildSectionTitle('Tags'),
                    const SizedBox(height: AppDimensions.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.tags.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.terracotta.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(t, style: AppTextStyles.bodySmall.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildImageSection(MarketplaceProduct product) {
    final hasImage = product.imageUrls.isNotEmpty && !product.imageUrls.first.startsWith('assets/');
    return GestureDetector(
      onTap: _changeImage,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 280,
            color: AppColors.warmBeige.withValues(alpha: 0.3),
            child: hasImage
                ? AdaptiveProductImage(imageUrl: product.imageUrls.first, fit: BoxFit.cover)
                : const Center(child: Icon(Icons.image_outlined, size: 64, color: AppColors.textSecondary)),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Tap image to change', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MarketplaceProduct product) {
    final isPublished = product.isPublished;
    final inStock = product.stockQuantity > 0;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isPublished ? AppColors.oliveGreen : Colors.orange).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isPublished ? 'Published' : 'Draft',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isPublished ? AppColors.oliveGreen : Colors.orange.shade700),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (inStock ? AppColors.oliveGreen : AppColors.error).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            inStock ? 'In Stock (${product.stockQuantity})' : 'Out of Stock',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: inStock ? AppColors.oliveGreen : AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailGrid(MarketplaceProduct product) {
    final fields = <MapEntry<String, String>>[];
    if (product.category.isNotEmpty) fields.add(MapEntry('Category', product.category));
    if (product.material != null && product.material!.isNotEmpty) fields.add(MapEntry('Material', product.material!));
    if (product.craftType != null && product.craftType!.isNotEmpty) fields.add(MapEntry('Craft Type', product.craftType!));
    if (product.dimensions != null && product.dimensions!.isNotEmpty) fields.add(MapEntry('Size / Dimensions', product.dimensions!));
    if (product.weight != null && product.weight!.isNotEmpty) fields.add(MapEntry('Weight', product.weight!));
    fields.add(MapEntry('Stock', '${product.stockQuantity}'));
    fields.add(MapEntry('Price', '₹${product.effectivePrice.toInt()}'));
    if (product.shippingInfo != null && product.shippingInfo!.isNotEmpty) fields.add(MapEntry('Shipping', product.shippingInfo!));

    if (fields.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          for (int i = 0; i < fields.length; i++) ...[
            if (i > 0) const Divider(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(fields[i].key, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: Text(fields[i].value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.charcoal));
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 8, AppDimensions.lg, AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/share-everywhere', arguments: widget.productId);
                },
                icon: const Text('📣', style: TextStyle(fontSize: 18)),
                label: const Text('Share Everywhere', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mustardGold,
                  foregroundColor: AppColors.charcoal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleteProduct,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToEdit,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
