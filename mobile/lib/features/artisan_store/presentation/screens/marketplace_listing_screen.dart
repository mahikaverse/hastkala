import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/models/models.dart';
import '../../../../core/models/listing_data.dart';
import '../../../../core/models/marketplace_template.dart';
import '../../../../core/models/export_record.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/services/marketplace_service.dart';
import '../../../../core/services/export_history_service.dart';
import '../../../../core/widgets/adaptive_product_image.dart';

class MarketplaceListingScreen extends StatefulWidget {
  final String marketplaceId;
  final List<String> selectedProductIds;
  const MarketplaceListingScreen({
    super.key,
    required this.marketplaceId,
    required this.selectedProductIds,
  });

  @override
  State<MarketplaceListingScreen> createState() => _MarketplaceListingScreenState();
}

class _MarketplaceListingScreenState extends State<MarketplaceListingScreen> {
  final DataService _data = DataService();
  final MarketplaceService _marketplace = MarketplaceService();
  final Map<String, ListingData> _listings = {};
  final Set<String> _preparing = {};
  final Set<String> _ready = {};
  bool _isExporting = false;

  MarketplaceTemplate get _template =>
      MarketplaceTemplate.templates.firstWhere((t) => t.id == widget.marketplaceId);

  ArtisanStore? get _store => _data.stores.isNotEmpty ? _data.stores.first : null;

  List<MarketplaceProduct> get _selectedProducts {
    if (_store == null) return [];
    final all = _data.getPublishedProductsByStore(_store!.id);
    return all.where((p) => widget.selectedProductIds.contains(p.id)).toList();
  }

  @override
  void initState() {
    super.initState();
    _initListings();
  }

  void _initListings() {
    for (final product in _selectedProducts) {
      _listings[product.id] = _marketplace.mapProductToMarketplace(product, _template);
    }
  }

  Future<void> _prepareAllWithAI() async {
    for (final product in _selectedProducts) {
      if (_ready.contains(product.id)) continue;
      if (!mounted) return;
      setState(() => _preparing.add(product.id));
      final listing = _listings[product.id];
      if (listing == null) {
        setState(() => _preparing.remove(product.id));
        continue;
      }
      final result = await _marketplace.prepareListingWithAI(listing, _template);
      if (result != null && mounted) {
        setState(() {
          _listings[product.id] = result;
          _preparing.remove(product.id);
          if (result.isReady) _ready.add(product.id);
        });
      } else if (mounted) {
        setState(() => _preparing.remove(product.id));
      }
    }
  }

  Future<void> _prepareSingleAI(String productId) async {
    setState(() => _preparing.add(productId));
    final listing = _listings[productId];
    if (listing == null) {
      setState(() => _preparing.remove(productId));
      return;
    }
    final result = await _marketplace.prepareListingWithAI(listing, _template);
    if (result != null && mounted) {
      setState(() {
        _listings[productId] = result;
        _preparing.remove(productId);
        if (result.isReady) _ready.add(productId);
      });
    } else if (mounted) {
      setState(() => _preparing.remove(productId));
    }
  }

  Future<void> _exportExcel() async {
    if (_listings.isEmpty) return;
    setState(() => _isExporting = true);

    final exportListings = _listings.values.toList();
    final file = await _marketplace.exportToExcel(exportListings, _template.name);

    if (mounted) {
      setState(() => _isExporting = false);
      final lang = LanguageProvider.of(context);
      if (file != null && await file.exists()) {
        final fileSize = await file.length();

        final record = ExportRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          marketplaceId: _template.id,
          marketplaceName: _template.name,
          fileName: file.path.split('/').last,
          filePath: file.path,
          exportedAt: DateTime.now(),
          productCount: exportListings.length,
          fileType: 'XLSX',
          fileSize: fileSize,
        );
        await ExportHistoryService().saveExport(record);

        try {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'HastKala ${_template.name} Listing',
          );
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_template.name} ${lang.t('exportSuccess')}'),
              backgroundColor: AppColors.oliveGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang.t('exportFailed')),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  void _updateListingField(String productId, String field, String value) {
    final current = _listings[productId];
    if (current == null) return;
    setState(() {
      switch (field) {
        case 'title':
          _listings[productId] = current.copyWith(title: value);
          break;
        case 'description':
          _listings[productId] = current.copyWith(description: value);
          break;
        case 'category':
          _listings[productId] = current.copyWith(category: value);
          break;
        case 'material':
          _listings[productId] = current.copyWith(material: value);
          break;
        case 'color':
          _listings[productId] = current.copyWith(color: value);
          break;
        case 'size':
          _listings[productId] = current.copyWith(size: value);
          break;
      }
      final updated = _listings[productId]!;
      _listings[productId] = _marketplace.validateListing(updated, _template);
      if (_listings[productId]!.isReady) {
        _ready.add(productId);
      } else {
        _ready.remove(productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _template.color,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_template.name} ${lang.t('listingPreparation')}',
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildActionBar(lang),
          Expanded(child: _buildProductList(lang)),
        ],
      ),
    );
  }

  Widget _buildActionBar(dynamic lang) {
    final anyPreparing = _preparing.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: anyPreparing ? null : _prepareAllWithAI,
                  icon: anyPreparing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(anyPreparing ? lang.t('aiPreparingListing') : lang.t('aiPrepareListing')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _template.color,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _template.color.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: (_isExporting || _listings.isEmpty) ? null : _exportExcel,
                icon: _isExporting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(lang.t('exportExcel')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.oliveGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.oliveGreen.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lang.t('downloadAndUploadNote'),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(dynamic lang) {
    if (_selectedProducts.isEmpty) {
      return Center(
        child: Text(lang.t('noProductsToExport'), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.lg),
      itemCount: _selectedProducts.length,
      itemBuilder: (_, i) {
        final product = _selectedProducts[i];
        final listing = _listings[product.id];
        final isPreparing = _preparing.contains(product.id);
        final isReady = _ready.contains(product.id);
        if (listing == null) return const SizedBox.shrink();
        return _buildProductListingCard(product, listing, isPreparing, isReady, lang);
      },
    );
  }

  Widget _buildProductListingCard(
    MarketplaceProduct product,
    ListingData listing,
    bool isPreparing,
    bool isReady,
    dynamic lang,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: isReady ? AppColors.oliveGreen.withValues(alpha: 0.4) : AppColors.borderLight,
          width: isReady ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 50, height: 50,
            child: AdaptiveProductImage(
              imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isReady)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.oliveGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.oliveGreen),
                    const SizedBox(width: 4),
                    Text(lang.t('listingReady'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.oliveGreen)),
                  ],
                ),
              ),
          ],
        ),
        subtitle: _buildListingSubtitle(listing, isPreparing, lang),
        children: [
          _buildListingDetails(listing, product.id, lang),
        ],
      ),
    );
  }

  Widget _buildListingSubtitle(ListingData listing, bool isPreparing, dynamic lang) {
    if (isPreparing) {
      return Row(
        children: [
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.terracotta)),
          const SizedBox(width: 6),
          Text(lang.t('aiPreparingListing'), style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      );
    }

    if (listing.missingCount > 0) {
      return Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            '${listing.missingCount} ${lang.t('detailsNeedAttention')}',
            style: TextStyle(fontSize: 11, color: AppColors.warning),
          ),
        ],
      );
    }

    return Text(
      '₹${listing.price.toInt()} • ${listing.category}',
      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
    );
  }

  Widget _buildListingDetails(ListingData listing, String productId, dynamic lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (listing.missingCount > 0) _buildMissingFieldsBanner(listing, lang),
        _buildEditableField(lang.t('productTitleLabel'), listing.title, (v) => _updateListingField(productId, 'title', v)),
        _buildEditableField(lang.t('description'), listing.description, (v) => _updateListingField(productId, 'description', v), maxLines: 4),
        if (listing.bulletPoints.isNotEmpty) _buildBulletPointsDisplay(listing.bulletPoints),
        if (listing.keywords.isNotEmpty) _buildKeywordsDisplay(listing.keywords),
        _buildEditableField(lang.t('category'), listing.category, (v) => _updateListingField(productId, 'category', v)),
        _buildEditableField(lang.t('material'), listing.material, (v) => _updateListingField(productId, 'material', v)),
        _buildInfoRow('Color', listing.color),
        _buildInfoRow('Size', listing.size),
        _buildInfoRow('Weight', listing.weight),
        _buildInfoRow(lang.t('price'), '₹${listing.price.toInt()}'),
        _buildInfoRow(lang.t('brandNameLabel'), listing.brand),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _prepareSingleAI(productId),
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: Text(lang.t('aiPrepareListing'), style: const TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _template.color,
                  side: BorderSide(color: _template.color.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMissingFieldsBanner(ListingData listing, dynamic lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${listing.missingCount} ${lang.t('detailsNeedAttention')}: ${listing.missingFields.join(", ")}',
              style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, String value, Function(String) onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: value.isEmpty ? AppColors.warning.withValues(alpha: 0.04) : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value.isEmpty ? AppColors.warning.withValues(alpha: 0.3) : AppColors.borderLight,
              ),
            ),
            child: TextFormField(
              initialValue: value,
              maxLines: maxLines,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: InputBorder.none,
                hintText: LanguageProvider.of(context).t('fieldRequiresAttention'),
                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.4), fontSize: 12),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPointsDisplay(List<String> bullets) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LanguageProvider.of(context).t('bulletPointsLabel'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          ...bullets.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.bold)),
                Expanded(child: Text(b, style: AppTextStyles.bodySmall.copyWith(fontSize: 12))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildKeywordsDisplay(List<String> keywords) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LanguageProvider.of(context).t('searchTermsLabel'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: keywords.map((k) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(k, style: TextStyle(fontSize: 10, color: AppColors.info, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 11, color: AppColors.charcoal))),
        ],
      ),
    );
  }
}
