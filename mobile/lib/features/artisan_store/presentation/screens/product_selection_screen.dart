import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/models/models.dart';
import '../../../../core/models/marketplace_template.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/widgets/adaptive_product_image.dart';
import '../../../../core/widgets/marketplace_logos.dart';

class ProductSelectionScreen extends StatefulWidget {
  final String marketplaceId;
  const ProductSelectionScreen({super.key, required this.marketplaceId});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final DataService _data = DataService();
  final Set<String> _selectedIds = {};

  MarketplaceTemplate get _template =>
      MarketplaceTemplate.templates.firstWhere((t) => t.id == widget.marketplaceId);

  ArtisanStore? get _store => _data.stores.isNotEmpty ? _data.stores.first : null;

  List<MarketplaceProduct> get _publishedProducts {
    if (_store == null) return [];
    return _data.getPublishedProductsByStore(_store!.id);
  }

  bool get _allSelected => _selectedIds.length == _publishedProducts.length;
  bool get _hasSelection => _selectedIds.isNotEmpty;

  void _toggleAll() {
    setState(() {
      if (_allSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_publishedProducts.map((p) => p.id));
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  void _toggleProduct(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _continueToPreparation() {
    if (!_hasSelection) return;
    Navigator.pushNamed(
      context,
      '/marketplace-listing',
      arguments: {
        'marketplaceId': widget.marketplaceId,
        'selectedProductIds': _selectedIds.toList(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _template.color,
        foregroundColor: Colors.white,
        title: Text(
          lang.t('selectProducts'),
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(lang),
          _buildSelectionBar(lang),
          Expanded(child: _buildProductList(lang)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(lang),
    );
  }

  Widget _buildHeader(dynamic lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MarketplaceLogos.forId(widget.marketplaceId, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('selectProducts'),
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.charcoal),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lang.t('selectProductsDesc').replaceAll('{marketplace}', _template.name),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(dynamic lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _template.color.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: _template.color.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _allSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: _template.color,
                ),
                const SizedBox(width: 6),
                Text(
                  _allSelected ? lang.t('clearSelection') : lang.t('selectAll'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _template.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (_hasSelection) ...[
            GestureDetector(
              onTap: _clearSelection,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(lang.t('clearSelection'), style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Spacer(),
          ] else
            const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _hasSelection ? _template.color : AppColors.textSecondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_selectedIds.length} ${lang.t('selected')}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _hasSelection ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(dynamic lang) {
    if (_publishedProducts.isEmpty) {
      return Center(
        child: Text(lang.t('noProductsToExport'), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.lg),
      itemCount: _publishedProducts.length,
      itemBuilder: (_, i) {
        final product = _publishedProducts[i];
        final isSelected = _selectedIds.contains(product.id);
        return _buildProductCard(product, isSelected, lang);
      },
    );
  }

  Widget _buildProductCard(MarketplaceProduct product, bool isSelected, dynamic lang) {
    return GestureDetector(
      onTap: () => _toggleProduct(product.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _template.color.withValues(alpha: 0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isSelected ? _template.color : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: AdaptiveProductImage(
                  imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.effectivePrice.toInt()}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brown, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (product.material != null && product.material!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.material!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? _template.color : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? _template.color : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(dynamic lang) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _hasSelection ? _continueToPreparation : null,
          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
          label: Text(
            _hasSelection
                ? '${lang.t('continueToPreparation')} (${_selectedIds.length})'
                : lang.t('selectAtLeastOne'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _template.color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _template.color.withValues(alpha: 0.4),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
          ),
        ),
      ),
    );
  }
}
