import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/language_provider.dart';
import '../models/product_draft.dart';

class SetPriceScreen extends StatefulWidget {
  final ProductDraft draft;

  const SetPriceScreen({super.key, required this.draft});

  @override
  State<SetPriceScreen> createState() => _SetPriceScreenState();
}

class _SetPriceScreenState extends State<SetPriceScreen> {
  late final TextEditingController _priceController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final initialPrice = widget.draft.expectedPrice ?? widget.draft.price ?? 700;
    _priceController = TextEditingController(text: '$initialPrice');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCheckPrice() {
    final entered = int.tryParse(_priceController.text.trim());
    if (entered == null || entered <= 0) {
      final lang = LanguageProvider.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.t('invalidPrice'))),
      );
      return;
    }

    widget.draft.expectedPrice = entered;
    widget.draft.price = entered;

    Navigator.pushNamed(
      context,
      '/ai-price-assistant',
      arguments: widget.draft,
    );
  }

  Widget _buildProductSummary() {
    Widget imageWidget;
    final path = widget.draft.imagePath;
    final lang = LanguageProvider.of(context);

    if (widget.draft.isBase64Image && path != null) {
      final base64Str = path.contains(',') ? path.split(',').last : path;
      try {
        imageWidget = Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
      } catch (_) {
        imageWidget = _placeholderImage();
      }
    } else if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        imageWidget = Image.file(file, fit: BoxFit.cover);
      } else {
        imageWidget = _placeholderImage();
      }
    } else {
      imageWidget = _placeholderImage();
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: SizedBox(width: 56, height: 56, child: imageWidget),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.draft.productName ?? lang.t('productFallback'),
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  widget.draft.craft ?? widget.draft.material ?? lang.t('traditionalCraft'),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.warmBeige,
      child: const Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang.t('setYourPrice'),
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.md),
              _buildProductSummary(),
              const SizedBox(height: AppDimensions.xxl),

              // Title
              Text(
                lang.t('howMuchSell'),
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.sm),

              // Subtitle
              Text(
                lang.t('tellUsPrice'),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xxxl),

              // Large ₹ input field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl, vertical: AppDimensions.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.terracotta.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.terracotta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _priceController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.terracotta,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: lang.t('priceHint'),
                          hintStyle: TextStyle(color: AppColors.warmBeige),
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                lang.t('examplePrice'),
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.xxl),

              // Reassurance info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppColors.mustardGold),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        lang.t('aiCheckPrice'),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.charcoal),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),

              // Button: Check Price
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onCheckPrice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                      const SizedBox(width: AppDimensions.sm),
                      Text(
                        lang.t('checkPrice'),
                        style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
