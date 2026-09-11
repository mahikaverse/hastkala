import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/product_draft.dart';

class CatalogPreviewScreen extends StatelessWidget {
  final ProductDraft draft;

  const CatalogPreviewScreen({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
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
          'Your Catalog',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductCard(),
                  const SizedBox(height: AppDimensions.xxl),
                  _buildMeetTheArtisan(),
                ],
              ),
            ),
          ),
          _buildContinueButton(context),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductTitle(),
                const SizedBox(height: AppDimensions.xs),
                _buildPrice(),
                const SizedBox(height: AppDimensions.md),
                _buildCraftCategory(),
                const SizedBox(height: AppDimensions.xl),
                _buildDescription(),
                const SizedBox(height: AppDimensions.xl),
                _buildTags(),
                const SizedBox(height: AppDimensions.xl),
                _buildAttributes(),
                if (draft.craftStory != null && draft.craftStory!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.xl),
                  _buildCraftStory(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final path = draft.imagePath;
    if (path == null) return _buildImagePlaceholder();

    Widget image;
    if (draft.isBase64Image) {
      image = Image.memory(
        _decodeBase64(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    } else {
      image = Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusLG),
      ),
      child: image,
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.warmBeige,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLG),
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 56, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildProductTitle() {
    return Text(
      draft.productName ?? 'Product Name',
      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.charcoal),
    );
  }

  Widget _buildPrice() {
    return Text(
      '₹---',
      style: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.terracotta,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildCraftCategory() {
    final craft = draft.craft;
    final category = draft.category;
    final parts = [craft, category].where((e) => e != null && e.isNotEmpty).toList();
    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(Icons.category_outlined, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.xs),
        Text(
          parts.join(' · '),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final craft = draft.craft ?? '';
    final material = draft.material ?? '';
    final color = draft.color ?? '';
    final name = draft.productName ?? 'product';

    final description = draft.description?.isNotEmpty == true
        ? draft.description!
        : '$name${material.isNotEmpty ? ' made with $material' : ''}${craft.isNotEmpty ? ' using $craft techniques' : ''}${color.isNotEmpty ? ' in $color' : ''}.';

    return Text(
      description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.charcoal,
        height: 1.6,
      ),
    );
  }

  Widget _buildTags() {
    final tags = [draft.material, draft.craft, draft.color]
        .where((e) => e != null && e.isNotEmpty)
        .toList();

    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                tag!,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAttributes() {
    final attributes = <MapEntry<String, String>>[];

    if (draft.size != null && draft.size!.isNotEmpty) {
      attributes.add(MapEntry('Size', draft.size!));
    }
    if (draft.weight != null && draft.weight!.isNotEmpty) {
      attributes.add(MapEntry('Weight', draft.weight!));
    }
    if (draft.quantity != null) {
      attributes.add(MapEntry('Quantity', draft.quantity.toString()));
    }
    if (draft.makingTime != null && draft.makingTime!.isNotEmpty) {
      attributes.add(MapEntry('Making Time', draft.makingTime!));
    }

    if (attributes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: AppTextStyles.titleSmall.copyWith(color: AppColors.charcoal),
        ),
        const SizedBox(height: AppDimensions.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: AppDimensions.md,
            mainAxisSpacing: AppDimensions.md,
          ),
          itemCount: attributes.length,
          itemBuilder: (context, index) {
            final attr = attributes[index];
            return Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    attr.key,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    attr.value,
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.charcoal),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCraftStory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_stories_outlined, size: 18, color: AppColors.mustardGold),
            const SizedBox(width: AppDimensions.xs),
            Text(
              'Craft Story',
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.charcoal),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: AppColors.cream.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            draft.craftStory!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.charcoal,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetTheArtisan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meet the Artisan',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.charcoal),
          ),
          const SizedBox(height: AppDimensions.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildArtisanPhoto(),
              const SizedBox(width: AppDimensions.lg),
              Expanded(child: _buildArtisanInfo()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanPhoto() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.warmBeige,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        size: 32,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildArtisanInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          draft.artisanName ?? 'Artisan Name',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal),
        ),
        const SizedBox(height: AppDimensions.xs),
        if (draft.artisanCraft != null || draft.craft != null)
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: AppDimensions.xs),
              Text(
                draft.artisanCraft ?? draft.craft ?? '',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        if (draft.artisanLocation != null || draft.location != null) ...[
          const SizedBox(height: AppDimensions.xs),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: AppDimensions.xs),
              Text(
                draft.artisanLocation ?? draft.location ?? '',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppDimensions.sm),
        Text(
          draft.artisanIntro ?? 'A skilled artisan passionate about traditional crafts',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.charcoal,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightLG,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/set-price',
                arguments: draft,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              elevation: 0,
            ),
            child: Text(
              'Continue',
              style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  static Uint8List _decodeBase64(String data) {
    final base64Str = data.contains(',') ? data.split(',').last : data;
    return base64Decode(base64Str);
  }
}
