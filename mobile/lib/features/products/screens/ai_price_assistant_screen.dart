import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/services/api_config.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/widgets/voice_mute_button.dart';
import '../models/product_draft.dart';

class AIPriceAssistantScreen extends StatefulWidget {
  final ProductDraft draft;

  const AIPriceAssistantScreen({super.key, required this.draft});

  @override
  State<AIPriceAssistantScreen> createState() => _AIPriceAssistantScreenState();
}

class _AIPriceAssistantScreenState extends State<AIPriceAssistantScreen> {
  bool _isLoading = true;
  int _expectedPrice = 0;
  int _marketMin = 0;
  int _marketMax = 0;
  int _recommendedMin = 0;
  int _recommendedMax = 0;
  int _suggestedPrice = 0;
  int _comparablesFound = 0;
  String _reason = '';
  List<dynamic> _sources = [];
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _expectedPrice = widget.draft.expectedPrice ?? widget.draft.price ?? 700;
    _ttsService.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playGuidance();
    });
    _fetchPriceSuggestion();
  }

  void _playGuidance() {
    if (!mounted) return;
    final lang = LanguageProvider.of(context);
    final langCode = lang.langCode;
    final text = langCode == 'hi' ? lang.t('priceAssistantTtsGuidanceHi') : lang.t('priceAssistantTtsGuidanceEn');
    _ttsService.speak(text, language: langCode);
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _fetchPriceSuggestion() async {
    setState(() {
      _isLoading = true;
    });

    final payload = {
      if (widget.draft.productName != null) 'product_name': widget.draft.productName,
      if (widget.draft.category != null) 'category': widget.draft.category,
      if (widget.draft.material != null) 'material': widget.draft.material,
      if (widget.draft.craft != null) 'craft': widget.draft.craft,
      if (widget.draft.color != null) 'color': widget.draft.color,
      if (widget.draft.size != null) 'size': widget.draft.size,
      if (widget.draft.makingTime != null) 'making_time': widget.draft.makingTime,
      if (widget.draft.location != null) 'location': widget.draft.location,
      'artisan_expected_price': _expectedPrice,
    };

    http.Response? response;
    for (final host in ApiConfig.candidateUrls) {
      try {
        final uri = Uri.parse('$host/api/ai/suggest-price');
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 12));

        if (res.statusCode == 200) {
          response = res;
          break;
        }
      } catch (_) {
        continue;
      }
    }

    if (!mounted) return;

    if (response != null && response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final int exp = data['artisan_expected_price'] ?? _expectedPrice;
        final int mMin = data['market_min'] ?? exp;
        final int mMax = data['market_max'] ?? (exp * 1.25).round();
        final int recMin = data['recommended_min'] ?? exp;
        final int recMax = data['recommended_max'] ?? (exp * 1.15).round();
        final int sugg = data['suggested_price'] ?? exp;
        final int compCount = data['comparables_found'] ?? 0;
        final String r = data['reason'] ??
            'AI suggested price based on similar handmade crafts and your expected price.';
        final List<dynamic> src = data['sources'] ?? [];

        setState(() {
          _isLoading = false;
          _expectedPrice = exp;
          _marketMin = mMin;
          _marketMax = mMax;
          _recommendedMin = recMin;
          _recommendedMax = recMax;
          _suggestedPrice = sugg;
          _comparablesFound = compCount;
          _reason = r;
          _sources = src;
        });

        // Save into draft for future reference
        widget.draft.expectedPrice = exp;
        widget.draft.suggestedPrice = sugg;
        widget.draft.marketMin = mMin;
        widget.draft.marketMax = mMax;
        widget.draft.recommendedMin = recMin;
        widget.draft.recommendedMax = recMax;
        widget.draft.priceReason = r;
        widget.draft.comparablesFound = compCount;
        widget.draft.priceSources = src;
        return;
      } catch (_) {}
    }

    // Graceful fallback if network is unreachable
    setState(() {
      _isLoading = false;
      _marketMin = (_expectedPrice * 0.85).round();
      _marketMax = (_expectedPrice * 1.25).round();
      _recommendedMin = (_expectedPrice * 0.9).round();
      _recommendedMax = (_expectedPrice * 1.15).round();
      _suggestedPrice = _expectedPrice;
      _comparablesFound = 0;
      _reason =
          "We couldn't find enough similar products for a reliable estimate. You have full control over your final selling price.";
    });
  }

  void _choosePriceAndProceed(int finalPrice) {
    _ttsService.stop();
    widget.draft.price = finalPrice;
    Navigator.pushNamed(context, '/ready-to-publish', arguments: widget.draft);
  }

  void _showEnterCustomPriceSheet() {
    final controller = TextEditingController(text: _suggestedPrice > 0 ? '$_suggestedPrice' : '$_expectedPrice');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
          ),
          padding: EdgeInsets.only(
            left: AppDimensions.xxl,
            right: AppDimensions.xxl,
            top: AppDimensions.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimensions.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text(
                'Enter Your Price',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.charcoal),
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'You decide the final selling price for your craft.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.xl),
              Row(
                children: [
                  Text('₹', style: AppTextStyles.displayLarge.copyWith(color: AppColors.terracotta)),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: AppTextStyles.displayLarge.copyWith(color: AppColors.terracotta),
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.terracotta, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.terracotta, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xxl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final customVal = int.tryParse(controller.text);
                    if (customVal != null && customVal > 0) {
                      Navigator.pop(ctx);
                      _choosePriceAndProceed(customVal);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                  child: Text(
                    'Confirm Price',
                    style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductThumbnail() {
    Widget imageWidget;
    final path = widget.draft.imagePath;

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
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: SizedBox(width: 52, height: 52, child: imageWidget),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.draft.productName ?? 'Product',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.draft.craft ?? widget.draft.material ?? 'Traditional Craft',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
      child: const Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 24),
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
          onPressed: () {
            _ttsService.stop();
            Navigator.pop(context);
          },
        ),
        title: Text(
          lang.t('aiPriceAssistant'),
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
        ),
        centerTitle: true,
        actions: [
          VoiceMuteButton(
            color: AppColors.cream,
            onReplay: _playGuidance,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoadingView() : _buildPriceAnalysisView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    final lang = LanguageProvider.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation(AppColors.terracotta),
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),
            Text(
              lang.t('letsCheckMarket'),
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              lang.t('researchingListings'),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xxl),
            _buildProductThumbnail(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAnalysisView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductThumbnail(),
                const SizedBox(height: AppDimensions.xl),
                _buildPriceCard(),
                const SizedBox(height: AppDimensions.xl),
                _buildWhyThisSuggestionCard(),
                const SizedBox(height: AppDimensions.lg),
                _buildTrustBanner(),
                const SizedBox(height: AppDimensions.xl),
              ],
            ),
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildPriceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suggested Price Spotlight
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.md, horizontal: AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.terracotta, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Suggested price',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.terracotta,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI recommendation',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Text(
                  '₹$_suggestedPrice',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.terracotta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // 3 Metric Rows
          _priceMetricRow('Your expected price', '₹$_expectedPrice', highlight: false),
          const Divider(height: AppDimensions.lg, color: AppColors.borderLight),
          _priceMetricRow('Market range', '₹$_marketMin – ₹$_marketMax', highlight: false),
          const Divider(height: AppDimensions.lg, color: AppColors.borderLight),
          _priceMetricRow('AI suggested range', '₹$_recommendedMin – ₹$_recommendedMax', highlight: true),
        ],
      ),
    );
  }

  Widget _priceMetricRow(String label, String value, {required bool highlight}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: highlight ? AppColors.charcoal : AppColors.textSecondary,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: highlight ? AppColors.terracotta : AppColors.charcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWhyThisSuggestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.mustardGold),
              const SizedBox(width: AppDimensions.sm),
              Text(
                'Why this suggestion?',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            _reason,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.charcoal, height: 1.4),
          ),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (widget.draft.material != null)
                _infoChip('Material: ${widget.draft.material}'),
              if (widget.draft.craft != null)
                _infoChip('Craft: ${widget.draft.craft}'),
              if (widget.draft.size != null)
                _infoChip('Size: ${widget.draft.size}'),
              if (_comparablesFound > 0)
                _infoChip('$_comparablesFound online sources checked'),
            ],
          ),
          if (_sources.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.md),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: AppDimensions.xs),
            Text(
              'Comparable online listings found:',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            ..._sources.map((s) {
              final title = s['title'] ?? 'Listing';
              final price = s['price'];
              final platform = s['source'] ?? 'Online Store';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 13, color: AppColors.oliveGreen),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$title ($platform)',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (price != null)
                      Text(
                        '₹$price',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoal,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: AppColors.brown, fontSize: 11),
      ),
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.oliveGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(color: AppColors.oliveGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 16, color: AppColors.oliveGreen),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              'AI gives a suggestion. You choose the final price.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.oliveGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.xl,
        AppDimensions.md,
        AppDimensions.xl,
        AppDimensions.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Primary: Use Suggested Price (if different from expected, or main recommendation)
          if (_suggestedPrice > 0 && _suggestedPrice != _expectedPrice) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _choosePriceAndProceed(_suggestedPrice),
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
                    const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Use ₹$_suggestedPrice',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
          ],

          // 2. Secondary: Keep Expected Price
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => _choosePriceAndProceed(_expectedPrice),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.charcoal,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
              child: Text(
                'Keep ₹$_expectedPrice',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.xs),

          // 3. Text Button: Enter Different Price
          TextButton(
            onPressed: _showEnterCustomPriceSheet,
            child: Text(
              'Enter Different Price',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.terracotta,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
