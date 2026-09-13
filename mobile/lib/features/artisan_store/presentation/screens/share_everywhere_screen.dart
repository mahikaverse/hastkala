import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/api_config.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/widgets/adaptive_product_image.dart';

class ShareEverywhereScreen extends StatefulWidget {
  final String productId;
  const ShareEverywhereScreen({super.key, required this.productId});

  @override
  State<ShareEverywhereScreen> createState() => _ShareEverywhereScreenState();
}

class _ShareEverywhereScreenState extends State<ShareEverywhereScreen> {
  final DataService _data = DataService();
  final TextEditingController _messageController = TextEditingController();

  // ─── Dual-language state ──────────────────────────────────────────
  String _selectedLanguage = 'en';
  String? _englishMessage;
  String? _hindiMessage;
  bool _isGeneratingEn = false;
  bool _isGeneratingHi = false;
  String? _errorEn;
  String? _errorHi;

  MarketplaceProduct? get _product => _data.getProduct(widget.productId);

  // Computed: current language's state
  bool get _isGenerating => _selectedLanguage == 'en' ? _isGeneratingEn : _isGeneratingHi;
  String? get _errorMessage => _selectedLanguage == 'en' ? _errorEn : _errorHi;
  bool get _hasCurrentMessage => (_selectedLanguage == 'en' ? _englishMessage : _hindiMessage) != null;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Save edits back to the cache for current language
    final text = _messageController.text;
    if (_selectedLanguage == 'en') {
      _englishMessage = text.isEmpty ? null : text;
    } else {
      _hindiMessage = text.isEmpty ? null : text;
    }
  }

  void _switchLanguage(String lang) {
    if (_selectedLanguage == lang) return;
    // Save current controller text to current language cache before switching
    _saveCurrentToCache();
    setState(() {
      _selectedLanguage = lang;
    });
    // Load new language's cached message into controller
    _syncControllerFromCache();
  }

  void _saveCurrentToCache() {
    final text = _messageController.text.trim();
    if (_selectedLanguage == 'en') {
      _englishMessage = text.isEmpty ? null : text;
    } else {
      _hindiMessage = text.isEmpty ? null : text;
    }
  }

  void _syncControllerFromCache() {
    final cached = _selectedLanguage == 'en' ? _englishMessage : _hindiMessage;
    if (cached != null && _messageController.text != cached) {
      _messageController.text = cached;
    } else if (cached == null && _messageController.text.isNotEmpty) {
      _messageController.clear();
    }
  }

  String get _fullShareText {
    final msg = _messageController.text.trim();
    return '$msg\n\n$_productLink';
  }

  String get _productLink {
    final slug = _data.stores.isNotEmpty ? _data.stores.first.slug : 'store';
    return 'https://hastkala.app/store/$slug/product/${widget.productId}';
  }

  // ─── AI MESSAGE GENERATION ──────────────────────────────────────

  Future<void> _generateMessage() async {
    final product = _product;
    if (product == null) return;

    // Clear error for current language
    setState(() {
      if (_selectedLanguage == 'en') {
        _isGeneratingEn = true;
        _errorEn = null;
      } else {
        _isGeneratingHi = true;
        _errorHi = null;
      }
    });

    final payload = {
      'product_name': product.name,
      'description': product.description.isNotEmpty ? product.description : null,
      'material': product.material,
      'craft_type': product.craftType,
      'price': product.effectivePrice,
      'category': product.category.isNotEmpty ? product.category : null,
      'tags': product.tags.isNotEmpty ? product.tags : null,
      'language': _selectedLanguage,
      'artisan_name': _data.stores.isNotEmpty ? _data.stores.first.name : null,
      'location': _data.stores.isNotEmpty ? _data.stores.first.location : null,
    };

    String? message;
    try {
      message = await _callBackend(payload);
    } catch (_) {}

    message ??= await _callGroqDirect(payload);

    if (!mounted) return;

    if (message != null && message.isNotEmpty) {
      setState(() {
        if (_selectedLanguage == 'en') {
          _englishMessage = message!;
          _isGeneratingEn = false;
        } else {
          _hindiMessage = message!;
          _isGeneratingHi = false;
        }
      });
      _syncControllerFromCache();
    } else {
      setState(() {
        final err = _selectedLanguage == 'hi'
            ? 'मैसेज नहीं बन पाया। फिर से कोशिश करो।'
            : 'Could not generate message. Please try again.';
        if (_selectedLanguage == 'en') {
          _errorEn = err;
          _isGeneratingEn = false;
        } else {
          _errorHi = err;
          _isGeneratingHi = false;
        }
      });
    }
  }

  Future<String?> _callBackend(Map<String, dynamic> payload) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/ai/generate-marketing-message');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 30));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data['success'] == true && data['message'] != null) {
        return data['message'] as String;
      }
    }
    return null;
  }

  Future<String?> _callGroqDirect(Map<String, dynamic> payload) async {
    final apiKey = ApiConfig.groqApiKey;
    if (apiKey.isEmpty) return null;

    final isHindi = payload['language'] == 'hi';

    // Step 1: Generate marketing message in English (reliable)
    final enPrompt = _buildPromptEn(payload);
    String? enMessage;
    try {
      final resp = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'qwen/qwen3.8-27b',
          'messages': [
            {'role': 'user', 'content': enPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 400,
        }),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        enMessage = data['choices']?[0]?['message']?['content']?.toString().trim();
      }
    } catch (_) {}

    if (enMessage == null || enMessage.isEmpty) return null;

    // If English requested, verify it's actually English (not Hindi)
    if (!isHindi) {
      if (_hasDevanagari(enMessage)) {
        enMessage = await _translateMessage(enMessage,
            'Translate the following Hindi marketing message to natural English. Keep emojis in the same positions. Return ONLY the English translation. Do NOT add explanations.');
      }
      return enMessage;
    }

    // Step 2: Hindi requested — translate the English message to Hindi
    final hiMessage = await _translateMessage(enMessage,
        'You are a professional Hindi translator. Translate the given English marketing message to natural, fluent conversational Hindi. Use Devanagari script only. Keep emojis in the same positions. Do NOT add any English words in the output. Return ONLY the Hindi translation.');

    return hiMessage ?? enMessage;
  }

  bool _hasDevanagari(String text) {
    for (final rune in text.runes) {
      if (rune >= 0x0900 && rune <= 0x097F) return true;
    }
    return false;
  }

  Future<String?> _translateMessage(String text, String systemPrompt) async {
    final apiKey = ApiConfig.groqApiKey;
    try {
      final resp = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'qwen/qwen3.8-27b',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': text},
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        }),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final translated = data['choices']?[0]?['message']?['content']?.toString().trim();
        if (translated != null && translated.isNotEmpty) return translated;
      }
    } catch (_) {}
    return null;
  }

  String _buildPromptEn(Map<String, dynamic> d) {
    final tags = (d['tags'] as List?)?.join(', ') ?? 'N/A';
    return '''Write a short, attractive marketing message (3-5 sentences max) for this Indian handcrafted product. Use emojis naturally. Mention price with ₹. End with a call-to-action. Return ONLY the message text.

Product: ${d['product_name']}
Description: ${d['description'] ?? 'N/A'}
Material: ${d['material'] ?? 'N/A'}
Craft: ${d['craft_type'] ?? 'N/A'}
Category: ${d['category'] ?? 'N/A'}
Price: ₹${d['price']}
Artisan: ${d['artisan_name'] ?? 'N/A'}
Location: ${d['location'] ?? 'N/A'}
Tags: $tags''';
  }

  // ─── SHARING ACTIONS ────────────────────────────────────────────

  Future<void> _shareWhatsApp() async {
    final text = _fullShareText;
    if (text.trim().isEmpty) return;
    final whatsappUri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      return;
    }
    final webUri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareFacebook() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final fbAppUri = Uri.parse('fb://share/dialog?link=${Uri.encodeComponent(_productLink)}&quote=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(fbAppUri)) {
      await launchUrl(fbAppUri, mode: LaunchMode.externalApplication);
      return;
    }
    final fbWebUri = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(_productLink)}&quote=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(fbWebUri)) {
      await launchUrl(fbWebUri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyMessage() {
    final text = _fullShareText;
    if (text.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_selectedLanguage == 'hi' ? '✅ संदेश कॉपी हो गया!' : '✅ Message copied!'),
        backgroundColor: AppColors.oliveGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _shareNative() async {
    final text = _fullShareText;
    if (text.trim().isEmpty) return;
    final uri = Uri.parse('sms:?body=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // ─── BUILD UI ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final lang = LanguageProvider.of(context);

    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.brown,
          foregroundColor: AppColors.cream,
          title: Text('Share Everywhere', style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.5)),
              const SizedBox(height: AppDimensions.md),
              Text(lang.t('noProductsYet'), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        title: Text(
          _selectedLanguage == 'hi' ? 'हर जगह शेयर करो' : 'Share Everywhere',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductPreview(product),
            const SizedBox(height: AppDimensions.lg),
            _buildLanguageSelector(),
            const SizedBox(height: AppDimensions.lg),
            _buildGenerateButton(),
            const SizedBox(height: AppDimensions.lg),
            if (_isGenerating) _buildLoadingState(),
            if (_errorMessage != null && !_isGenerating) _buildErrorState(),
            if (_hasCurrentMessage && !_isGenerating) ...[
              _buildMessageEditor(),
              const SizedBox(height: AppDimensions.lg),
              _buildShareActions(),
            ],
            if (!_hasCurrentMessage && !_isGenerating && _errorMessage == null) _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPreview(MarketplaceProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppDimensions.radiusMD)),
            child: SizedBox(
              width: 100, height: 100,
              child: AdaptiveProductImage(
                imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('₹${product.effectivePrice.toInt()}', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.brown, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (product.material != null && product.material!.isNotEmpty)
                    Text(product.material!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedLanguage == 'hi' ? 'भाषा चुनो' : 'Select Language',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.charcoal),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _switchLanguage('en'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedLanguage == 'en' ? AppColors.terracotta : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: _selectedLanguage == 'en' ? AppColors.terracotta : AppColors.borderLight),
                  ),
                  child: Center(child: Text('English', style: TextStyle(fontWeight: FontWeight.w600, color: _selectedLanguage == 'en' ? Colors.white : AppColors.charcoal))),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: GestureDetector(
                onTap: () => _switchLanguage('hi'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedLanguage == 'hi' ? AppColors.terracotta : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: _selectedLanguage == 'hi' ? AppColors.terracotta : AppColors.borderLight),
                  ),
                  child: Center(child: Text('हिन्दी', style: TextStyle(fontWeight: FontWeight.w600, color: _selectedLanguage == 'hi' ? Colors.white : AppColors.charcoal))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    final isHi = _selectedLanguage == 'hi';
    final hasMsg = _hasCurrentMessage;
    final genLabel = hasMsg
        ? (isHi ? '🔄 फिर से बनाओ' : '🔄 Regenerate')
        : (isHi ? '✨ AI से बनाओ' : '✨ Generate with AI');

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generateMessage,
        icon: _isGenerating
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.auto_awesome_rounded, size: 20),
        label: Text(genLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.terracotta.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      margin: const EdgeInsets.only(bottom: AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.terracotta, strokeWidth: 2.5),
          const SizedBox(height: AppDimensions.md),
          Text(
            _selectedLanguage == 'hi' ? 'AI आपके लिए आकर्षक मैसेज बना रहा है...' : 'AI is crafting your marketing message...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      margin: const EdgeInsets.only(bottom: AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(_errorMessage!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isHi = _selectedLanguage == 'hi';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(Icons.campaign_rounded, size: 48, color: AppColors.terracotta.withValues(alpha: 0.4)),
          const SizedBox(height: AppDimensions.md),
          Text(
            isHi ? 'अपने प्रोडक्ट का आकर्षक मैसेज बनवाओ\nऔर हर जगह शेयर करो!' : 'Generate an attractive marketing message\nfor your product and share it everywhere!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            isHi ? 'ऊपर "AI से बनाओ" दबाओ' : 'Tap "Generate with AI" above',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageEditor() {
    final isHi = _selectedLanguage == 'hi';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.terracotta, size: 20),
            const SizedBox(width: 6),
            Text(
              isHi ? 'आपका मैसेज' : 'Your Message',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.charcoal),
            ),
            const Spacer(),
            Text('${_messageController.text.length}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 8,
            minLines: 5,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
            decoration: InputDecoration(
              hintText: isHi ? 'यहाँ अपना मैसेज बदल सकते हो...' : 'Edit your message here...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isHi ? 'टिप: मैसेज में अपनी ज़रूरत के अनुसार बदलाव कर सकते हो' : 'Tip: You can edit the message to fit your needs',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildShareActions() {
    final isHi = _selectedLanguage == 'hi';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHi ? 'शेयर करो' : 'Share Now',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.charcoal),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            Expanded(child: _buildShareButton(icon: Icons.chat_rounded, label: 'WhatsApp', color: const Color(0xFF25D366), onTap: _shareWhatsApp)),
            const SizedBox(width: 10),
            Expanded(child: _buildShareButton(icon: Icons.facebook_rounded, label: 'Facebook', color: const Color(0xFF1877F2), onTap: _shareFacebook)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildShareButton(icon: Icons.copy_rounded, label: isHi ? 'कॉपी' : 'Copy', color: AppColors.brown, onTap: _copyMessage)),
            const SizedBox(width: 10),
            Expanded(child: _buildShareButton(icon: Icons.share_rounded, label: isHi ? 'और' : 'More', color: AppColors.charcoal, onTap: _shareNative)),
          ],
        ),
        const SizedBox(height: AppDimensions.lg),
        _buildProductLinkPreview(),
      ],
    );
  }

  Widget _buildShareButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductLinkPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_productLink, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
