import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/data_service.dart';
import '../models/product_draft.dart';

class ReadyToPublishScreen extends StatefulWidget {
  final ProductDraft draft;

  const ReadyToPublishScreen({super.key, required this.draft});

  @override
  State<ReadyToPublishScreen> createState() => _ReadyToPublishScreenState();
}

class _ReadyToPublishScreenState extends State<ReadyToPublishScreen> {
  bool _isPublishing = false;

  Widget _buildImage() {
    final draft = widget.draft;
    if (draft.isBase64Image && draft.imagePath != null) {
      final base64Str = draft.imagePath!.contains(',')
          ? draft.imagePath!.split(',').last
          : draft.imagePath!;
      try {
        return Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
      } catch (_) {
        return _buildPlaceholder();
      }
    } else if (draft.imagePath != null) {
      final file = File(draft.imagePath!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.warmBeige,
      child: const Icon(Icons.image, color: AppColors.textSecondary, size: 40),
    );
  }

  Future<void> _handlePublish() async {
    if (_isPublishing) return;
    setState(() => _isPublishing = true);

    try {
      await DataService().publishProductDraft(widget.draft);

      if (mounted) {
        Navigator.of(context).pushNamed(
          '/publish-success',
          arguments: widget.draft,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note: Product saved locally. Error syncing: $e'),
            backgroundColor: AppColors.terracotta,
          ),
        );
        Navigator.of(context).pushNamed(
          '/publish-success',
          arguments: widget.draft,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cream),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ready to Publish',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.cream),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                        child: SizedBox(
                          width: 90,
                          height: 90,
                          child: _buildImage(),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              draft.productName ?? 'Product',
                              style: AppTextStyles.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              draft.price != null ? '₹${draft.price}' : '₹---',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.terracotta,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              draft.craft ?? '',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              draft.artisanName ?? 'Artisan',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              draft.artisanLocation ?? draft.location ?? '',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              Text(
                'Checklist',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppDimensions.md),
              _buildCheckItem('Product details'),
              _buildCheckItem('Enhanced photo'),
              _buildCheckItem('Description'),
              _buildCheckItem('Craft story'),
              _buildCheckItem('Artisan profile'),
              const SizedBox(height: AppDimensions.xxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPublishing ? null : _handlePublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: AppColors.cream,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.md,
                      horizontal: AppDimensions.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    elevation: 0,
                  ),
                  child: _isPublishing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cream),
                          ),
                        )
                      : Text(
                          'Publish Product',
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: AppColors.cream,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brown,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.md,
                      horizontal: AppDimensions.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                  child: Text(
                    'Save as Draft',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.brown,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.oliveGreen,
            size: 22,
          ),
          const SizedBox(width: AppDimensions.sm),
          Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
