import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/models/models.dart';
import '../../../../core/models/marketplace_template.dart';
import '../../../../core/models/export_record.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/services/export_history_service.dart';
import '../../../../core/widgets/marketplace_logos.dart';

class MarketplaceHubScreen extends StatefulWidget {
  const MarketplaceHubScreen({super.key});

  @override
  State<MarketplaceHubScreen> createState() => _MarketplaceHubScreenState();
}

class _MarketplaceHubScreenState extends State<MarketplaceHubScreen> {
  final DataService _data = DataService();
  final ExportHistoryService _exportHistory = ExportHistoryService();
  List<ExportRecord> _exports = [];

  ArtisanStore? get _store => _data.stores.isNotEmpty ? _data.stores.first : null;

  List get _publishedProducts {
    if (_store == null) return [];
    return _data.getPublishedProductsByStore(_store!.id);
  }

  @override
  void initState() {
    super.initState();
    _loadExports();
  }

  Future<void> _loadExports() async {
    await _exportHistory.init();
    if (mounted) {
      setState(() => _exports = _exportHistory.records);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    final publishedCount = _publishedProducts.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        title: Text(
          lang.t('marketplaceHub'),
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
        ),
        centerTitle: true,
      ),
      body: publishedCount == 0
          ? _buildEmptyState(lang)
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              children: [
                _buildHeaderCard(lang, publishedCount),
                const SizedBox(height: AppDimensions.lg),
                _buildSmartCatalogueCard(lang, publishedCount),
                const SizedBox(height: AppDimensions.lg),
                _buildMarketplaceList(lang),
                const SizedBox(height: AppDimensions.lg),
                _buildNoteCard(lang),
                if (_exports.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.xl),
                  _buildRecentExportsSection(lang),
                ],
              ],
            ),
    );
  }

  Widget _buildEmptyState(dynamic lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: AppDimensions.lg),
            Text(
              lang.t('noProductsToExport'),
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              lang.t('publishFirst'),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(dynamic lang, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.terracotta, AppColors.brown],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(color: AppColors.terracotta.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.public_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('listCraftEverywhere'),
                      style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lang.t('listCraftEverywhereDesc'),
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
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

  Widget _buildSmartCatalogueCard(dynamic lang, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.oliveGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.oliveGreen, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.t('smartCatalogue'), style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                const SizedBox(height: 4),
                Text(
                  '$count ${lang.t('productsReadyExport')}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.oliveGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceList(dynamic lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('prepareListing'),
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.charcoal),
        ),
        const SizedBox(height: AppDimensions.md),
        ...MarketplaceTemplate.templates.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMarketplaceRow(t, lang),
        )),
      ],
    );
  }

  Widget _buildMarketplaceRow(MarketplaceTemplate template, dynamic lang) {
    String descKey;
    switch (template.id) {
      case 'amazon':
        descKey = 'amazonDesc';
        break;
      case 'flipkart':
        descKey = 'flipkartDesc';
        break;
      case 'blinkit':
        descKey = 'blinkitDesc';
        break;
      default:
        descKey = 'otherDesc';
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/marketplace-product-selection',
        arguments: {'marketplaceId': template.id},
      ).then((_) => _loadExports()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            MarketplaceLogos.forId(template.id, size: 52),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.charcoal, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang.t(descKey),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: template.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang.t('prepareListing'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(dynamic lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lang.t('downloadAndUploadNote'),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.info, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ─── RECENT EXPORTS ─────────────────────────────────────────────────────

  Widget _buildRecentExportsSection(dynamic lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('recentExports'),
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.charcoal),
        ),
        const SizedBox(height: 4),
        Text(
          lang.t('recentExportsDesc'),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: AppDimensions.md),
        ..._exports.take(10).map((record) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildExportCard(record, lang),
        )),
      ],
    );
  }

  Widget _buildExportCard(ExportRecord record, dynamic lang) {
    final file = File(record.filePath);
    final fileExists = file.existsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: fileExists ? AppColors.borderLight : AppColors.error.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MarketplaceLogos.forId(record.marketplaceId, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.marketplaceName,
                      style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.charcoal, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.fileName,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildExportMenu(record, lang),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildExportBadge('${record.productCount} ${lang.t('products')}', Icons.inventory_2_outlined),
              const SizedBox(width: 8),
              _buildExportBadge(record.fileType, Icons.description_outlined),
              const SizedBox(width: 8),
              _buildExportBadge(_formatDate(record.exportedAt, lang), Icons.access_time_outlined),
              if (!fileExists) ...[
                const SizedBox(width: 8),
                _buildExportBadge(lang.t('fileMissing'), Icons.error_outline, isError: true),
              ],
            ],
          ),
          if (fileExists) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: lang.t('open'),
                    icon: Icons.open_in_new_rounded,
                    onTap: () => _openExport(record),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    label: lang.t('share'),
                    icon: Icons.share_rounded,
                    onTap: () => _shareExport(record),
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportBadge(String label, IconData icon, {bool isError = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isError ? AppColors.error.withValues(alpha: 0.08) : AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isError ? AppColors.error : AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.terracotta : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: isPrimary ? null : Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isPrimary ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportMenu(ExportRecord record, dynamic lang) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') _confirmDelete(record, lang);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              const SizedBox(width: 8),
              Text(lang.t('delete'), style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
      child: Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
    );
  }

  String _formatDate(DateTime date, dynamic lang) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return lang.t('justNow');
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _openExport(ExportRecord record) async {
    final file = File(record.filePath);
    if (!file.existsSync()) return;

    final uri = Uri.file(record.filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageProvider.of(context).t('noAppToOpen')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _shareExport(ExportRecord record) async {
    final file = File(record.filePath);
    if (!file.existsSync()) return;

    try {
      await Share.shareXFiles(
        [XFile(record.filePath)],
        text: 'HastKala ${record.marketplaceName} Listing',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LanguageProvider.of(context).t('exportFailed')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _confirmDelete(ExportRecord record, dynamic lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLG)),
        title: Text(lang.t('deleteExportConfirm')),
        content: Text(lang.t('deleteExportDesc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.t('cancel'), style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _exportHistory.deleteExport(record.id);
              if (mounted) setState(() => _exports = _exportHistory.records);
            },
            child: Text(lang.t('delete'), style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
