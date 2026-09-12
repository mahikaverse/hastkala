import 'package:flutter/material.dart';
import '../../../../core/localization/language_provider.dart';

import '../../../app/router.dart';
import '../../../core/localization/language_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/product_draft.dart';

class ArtisanAddProductScreen extends StatefulWidget {
  const ArtisanAddProductScreen({super.key});

  @override
  State<ArtisanAddProductScreen> createState() => _ArtisanAddProductScreenState();
}

class _ArtisanAddProductScreenState extends State<ArtisanAddProductScreen> {
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCamera());
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isProcessing
                  ? _buildProcessingState()
                  : _buildWaitingForPhoto(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final lang = LanguageProvider.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          Expanded(
            child: Text(
              lang.t('addYourCraft'),
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.charcoal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForPhoto() {
    final lang = LanguageProvider.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.terracotta.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.camera_alt_rounded,
              color: AppColors.terracotta,
              size: 44,
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          Text(
            lang.t('openingCamera'),
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            lang.t('takePhotoOfCraft'),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.xxl),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.terracotta),
            ),
          ),
          const SizedBox(height: AppDimensions.xxl),
          GestureDetector(
            onTap: _openCamera,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.xl,
                vertical: AppDimensions.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.terracotta,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: AppColors.cream, size: 18),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    lang.t('openCamera'),
                    style: AppTextStyles.buttonMedium.copyWith(color: AppColors.cream),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState() {
    final lang = LanguageProvider.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warmBeige.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(AppColors.terracotta),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(
              _statusMessage ?? lang.t('processing'),
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              lang.t('pleaseWait'),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openCamera() async {
    final result = await Navigator.pushNamed(context, AppRoutes.customCamera);
    if (result != null && result is String) {
      _navigateToImageStudio(result);
    }
  }

  void _navigateToImageStudio(String imagePath) async {
    if (!mounted) return;

    final lang = LanguageProvider.of(context);
    setState(() {
      _isProcessing = true;
      _statusMessage = lang.t('enhancingPhoto');
    });

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.aiImageStudio,
      arguments: imagePath,
    );

    if (!mounted) return;

    if (result != null && result is Map<String, dynamic>) {
      final String? returnedPath = result['imagePath'] as String?;
      final bool useEnhanced = result['useEnhanced'] == true;

      if (returnedPath != null) {
        final draft = ProductDraft(
          imagePath: returnedPath,
          useEnhanced: useEnhanced,
        );

        setState(() {
          _statusMessage = lang.t('preparingVoice');
        });

        Navigator.pushNamed(
          context,
          AppRoutes.tellAboutProduct,
          arguments: draft,
        ).then((_) {
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _statusMessage = null;
            });
          }
        });
      } else {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    } else {
      setState(() {
        _isProcessing = false;
        _statusMessage = null;
      });
    }
  }
}
