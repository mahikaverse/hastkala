import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';

class AIProductStudioScreen extends StatefulWidget {
  const AIProductStudioScreen({super.key});

  @override
  State<AIProductStudioScreen> createState() => _AIProductStudioScreenState();
}

class _AIProductStudioScreenState extends State<AIProductStudioScreen> {
  bool _isProcessing = true;
  int _currentStep = 0;

  final List<String> _steps = [
    'Product detected',
    'Craft type identified',
    'Materials identified',
    'Style identified',
    'Creating description',
    'Suggesting price',
    'Finding markets',
  ];

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  void _startProcessing() {
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      } else {
        timer.cancel();
        setState(() => _isProcessing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Product Studio', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
            Text('Turning your craft into a market-ready listing', style: AppTextStyles.bodySmall.copyWith(color: AppColors.cream.withValues(alpha: 0.8))),
          ],
        ),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputPreview(),
            const SizedBox(height: AppDimensions.xxl),
            if (_isProcessing) _buildProcessingCard() else _buildResultSection(),
            if (!_isProcessing) ...[
              const SizedBox(height: AppDimensions.xxl),
              _buildGeneratedDescription(),
              const SizedBox(height: AppDimensions.xxl),
              _buildNextButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputPreview() {
    final product = MockProducts.all[0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Input Preview', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: Image.network(
            product.imageUrl,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            cacheWidth: 400,
            cacheHeight: 200,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: 160,
              color: AppColors.warmBeige,
              child: Icon(Icons.image_outlined, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.mic, size: 16, color: AppColors.mustardGold),
                  const SizedBox(width: 4),
                  Text('Voice Description', style: AppTextStyles.labelMedium),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ye haath se banaya hua mitti ka decorative pot hai...',
                style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
              Text('Language: Hindi', style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.mustardGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.mustardGold),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text('HastKala AI is analyzing your craft...', style: AppTextStyles.titleSmall.copyWith(color: AppColors.mustardGold)),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          ...List.generate(_steps.length, (i) {
            final isDone = i < _currentStep;
            final isCurrent = i == _currentStep;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sm),
              child: Row(
                children: [
                  Icon(
                    isDone ? Icons.check_circle : (isCurrent ? Icons.radio_button_checked : Icons.circle_outlined),
                    size: 18,
                    color: isDone ? AppColors.oliveGreen : (isCurrent ? AppColors.mustardGold : AppColors.border),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    _steps[i],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDone ? AppColors.charcoal : (isCurrent ? AppColors.mustardGold : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Result', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        _resultRow('Product detected', 'Terracotta Decorative Pot'),
        _resultRow('Craft', 'Hand-painted Terracotta'),
        _resultRow('Material', 'Natural Clay'),
        _resultRow('Technique', 'Traditional Hand Painting'),
        _resultRow('Region', 'Rajasthan'),
      ],
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildGeneratedDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Generated Description', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: Text(
            'Handcrafted terracotta d\u00E9cor created by skilled Indian artisans using traditional painting techniques. This decorative pot showcases the rich cultural heritage of Rajasthan with intricate hand-painted designs.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Row(
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
              ),
              child: Text('Regenerate', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.charcoal)),
            ),
            const SizedBox(width: AppDimensions.md),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.terracotta),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
              ),
              child: Text('Edit', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, AppRoutes.smartCatalog),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.cream,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
      ),
      child: Text('Review My Listing', style: AppTextStyles.buttonLarge.copyWith(color: AppColors.cream)),
    );
  }
}
