import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/data_service.dart';

class VoiceAddProductScreen extends StatefulWidget {
  const VoiceAddProductScreen({super.key});

  @override
  State<VoiceAddProductScreen> createState() => _VoiceAddProductScreenState();
}

enum _SpeechState { idle, listening, processing, done }

enum _FlowStep { voice, form, preview }

class _VoiceAddProductScreenState extends State<VoiceAddProductScreen> {
  final DataService _data = DataService();
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _categoryCtrl = TextEditingController();
  final TextEditingController _materialCtrl = TextEditingController();
  final TextEditingController _makingTimeCtrl = TextEditingController();
  final TextEditingController _tagsCtrl = TextEditingController();

  _FlowStep _step = _FlowStep.voice;
  _SpeechState _speechState = _SpeechState.idle;
  String _rawTranscript = '';
  final List<String> _images = [];
  String _selectedCategory = '';

  static const _categories = [
    'Woodwork',
    'Pottery',
    'Textiles',
    'Jewelry',
    'Metalwork',
    'Paintings',
    'Stone Craft',
    'Leather',
    'Bamboo',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _speech.cancel();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    _materialCtrl.dispose();
    _makingTimeCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      await _speech.initialize(
        onError: (e) {
          if (mounted) {
            setState(() => _speechState = _SpeechState.idle);
            if (e.errorMsg != 'error_speech_timeout') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Speech error: ${e.errorMsg}')),
              );
            }
          }
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (_speechState == _SpeechState.listening && mounted) {
              setState(() => _speechState = _SpeechState.processing);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) _parseAndPopulate();
              });
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _speechState = _SpeechState.idle);
      }
    }
  }

  Future<void> _startListening() async {
    try {
      if (!_speech.isAvailable) {
        await _initSpeech();
      }
      if (!_speech.isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition not available')),
          );
        }
        return;
      }
      setState(() {
        _speechState = _SpeechState.listening;
        _rawTranscript = '';
      });
      await _speech.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          localeId: 'en_IN',
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _speechState = _SpeechState.idle);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start speech recognition')),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (_speechState == _SpeechState.listening && mounted) {
      setState(() => _speechState = _SpeechState.processing);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _parseAndPopulate();
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() => _rawTranscript = result.recognizedWords);
    }
  }

  void _parseAndPopulate() {
    final text = _rawTranscript.toLowerCase();

    // Extract price
    final pricePatterns = [
      RegExp(r'(?:price|keemat|kimat|rate|cost)\s*(?:is|hai|:)?\s*(\d[\d,]*)'),
      RegExp(r'(\d[\d,]*)\s*(?:rupees?|rupaye|rs\.?|₹)'),
      RegExp(r'₹\s*(\d[\d,]*)'),
    ];
    for (final p in pricePatterns) {
      final m = p.firstMatch(text);
      if (m != null) {
        _priceCtrl.text = m.group(1)!.replaceAll(',', '');
        break;
      }
    }

    // Extract material
    final materials = [
      'wood', 'wooden', 'sheesham', 'sandalwood', 'teak', 'bamboo',
      'clay', 'terracotta', 'ceramic', 'porcelain',
      'cotton', 'silk', 'wool', 'linen', 'jute',
      'silver', 'gold', 'copper', 'brass', 'bronze',
      'leather', 'stone', 'marble', 'granite',
      'paper', 'glass', 'recycled',
    ];
    for (final m in materials) {
      if (text.contains(m)) {
        _materialCtrl.text = m[0].toUpperCase() + m.substring(1);
        break;
      }
    }

    // Extract category
    final categoryMap = {
      'woodwork': ['wood', 'wooden', 'furniture', 'carving', 'sheesham', 'sandalwood', 'teak', 'bamboo'],
      'pottery': ['clay', 'pottery', 'terracotta', 'ceramic', 'vase', 'pot'],
      'textiles': ['cloth', 'fabric', 'cotton', 'silk', 'wool', 'weaving', 'embroidery', 'saree', 'dupatta'],
      'jewelry': ['jewelry', 'jewellery', 'necklace', 'earring', 'bangle', 'ring', 'bracelet', 'silver', 'gold'],
      'metalwork': ['metal', 'brass', 'copper', 'bronze', 'iron', 'steel'],
      'paintings': ['painting', 'canvas', 'art', 'drawing', 'mural', 'miniature'],
      'stone craft': ['stone', 'marble', 'granite', 'carving'],
      'leather': ['leather', 'bag', 'wallet', 'belt', 'jacket'],
      'bamboo': ['bamboo', 'cane', 'wicker'],
    };
    for (final entry in categoryMap.entries) {
      for (final kw in entry.value) {
        if (text.contains(kw)) {
          _selectedCategory = entry.key;
          _categoryCtrl.text = entry.key[0].toUpperCase() + entry.key.substring(1);
          break;
        }
      }
      if (_selectedCategory.isNotEmpty) break;
    }

    // Extract making time
    final timePatterns = [
      RegExp(r'(?:take[s]?|lag[e]?(?:ta|ti)?|banane\s*me)\s*(?:about|around| roughly)?\s*(\d+)\s*(days?|weeks?|months?|din|hafta|mahina)'),
      RegExp(r'(\d+)\s*(days?|weeks?|months?|din|hafta|mahina)'),
    ];
    for (final p in timePatterns) {
      final m = p.firstMatch(text);
      if (m != null) {
        _makingTimeCtrl.text = '${m.group(1)} ${m.group(2)}';
        break;
      }
    }

    // Extract name from first sentence or key phrase
    final namePatterns = [
      RegExp(r'(?:this is|ye hai|yeh hai|this is a)\s+(.+?)(?:,\s*made|,\s*it|i made|i have made)'),
      RegExp(r'(?:this is|ye hai|yeh hai)\s+(.+?)$'),
    ];
    for (final p in namePatterns) {
      final m = p.firstMatch(_rawTranscript);
      if (m != null) {
        var name = m.group(1)!.trim();
        if (name.length > 60) name = name.substring(0, 60);
        _nameCtrl.text = name[0].toUpperCase() + name.substring(1);
        break;
      }
    }

    // Use full transcript as description if description empty
    if (_descCtrl.text.isEmpty && _rawTranscript.isNotEmpty) {
      _descCtrl.text = _rawTranscript;
    }

    // Tags from common words
    final tagWords = <String>[];
    final tagKeywords = [
      'handmade', 'handcrafted', 'artisan', 'traditional', 'ethnic',
      'modern', 'vintage', 'organic', 'eco', 'sustainable',
    ];
    for (final kw in tagKeywords) {
      if (text.contains(kw)) tagWords.add(kw);
    }
    if (tagWords.isNotEmpty) _tagsCtrl.text = tagWords.join(', ');

    setState(() {
      _speechState = _SpeechState.done;
      _step = _FlowStep.form;
    });
  }

  void _addImage() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _addPlaceholderImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _addPlaceholderImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addPlaceholderImage() {
    setState(() {
      _images.add('assets/logo.png');
    });
  }

  void _publishProduct() {
    final store = _data.stores.isNotEmpty ? _data.stores.first : null;
    if (store == null) return;

    final product = MarketplaceProduct(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      storeId: store.id,
      artisanId: store.artisanId,
      name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Untitled Product',
      description: _descCtrl.text,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      category: _categoryCtrl.text.isNotEmpty ? _categoryCtrl.text : 'Other',
      material: _materialCtrl.text.isNotEmpty ? _materialCtrl.text : null,
      imageUrls: _images,
      isPublished: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _data.addProduct(product);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product published successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.brown),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _step == _FlowStep.voice
              ? 'Add Product'
              : _step == _FlowStep.form
                  ? 'Product Details'
                  : 'Preview Product',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.brown),
        ),
        centerTitle: true,
      ),
      body: _step == _FlowStep.voice
          ? _buildVoiceStep()
          : _step == _FlowStep.form
              ? _buildFormStep()
              : _buildPreviewStep(),
    );
  }

  // ─── STEP 1: VOICE INPUT ─────────────────────────────────────────────────

  Widget _buildVoiceStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Microphone icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _speechState == _SpeechState.listening
                            ? AppColors.terracotta.withValues(alpha: 0.15)
                            : AppColors.warmBeige.withValues(alpha: 0.5),
                        border: Border.all(
                          color: _speechState == _SpeechState.listening
                              ? AppColors.terracotta
                              : AppColors.divider,
                          width: 2,
                        ),
                      ),
                      child: _speechState == _SpeechState.processing
                          ? const Padding(
                              padding: EdgeInsets.all(25),
                              child: CircularProgressIndicator(
                                color: AppColors.terracotta,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(
                              _speechState == _SpeechState.listening
                                  ? Icons.mic
                                  : Icons.mic_none,
                              size: 40,
                              color: _speechState == _SpeechState.listening
                                  ? AppColors.terracotta
                                  : AppColors.brown,
                            ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tell us about your product',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.brown,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Speak naturally \u2014 we\'ll fill the details for you.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Transcript preview
                    if (_rawTranscript.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMD),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          _rawTranscript,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.charcoal,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Speak / Stop button
                    GestureDetector(
                      onTap: () {
                        if (_speechState == _SpeechState.listening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _speechState == _SpeechState.listening
                              ? AppColors.error
                              : AppColors.terracotta,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMD),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _speechState == _SpeechState.listening
                                  ? Icons.stop
                                  : Icons.mic,
                              color: AppColors.cream,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _speechState == _SpeechState.listening
                                  ? 'Stop Recording'
                                  : 'Tap to Speak',
                              style: AppTextStyles.buttonLarge.copyWith(
                                color: AppColors.cream,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Skip to form
                    TextButton(
                      onPressed: () => setState(() => _step = _FlowStep.form),
                      child: Text(
                        'Fill form manually',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── STEP 2: FORM REVIEW ─────────────────────────────────────────────────

  Widget _buildFormStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg).add(
        const EdgeInsets.only(bottom: 100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voice transcript banner
          if (_rawTranscript.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.oliveGreen.withValues(alpha: 0.08),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(
                  color: AppColors.oliveGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      size: 18, color: AppColors.oliveGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Fields filled from your voice. Edit anything below.',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.oliveGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Speak Again button
          if (_rawTranscript.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _step = _FlowStep.voice),
                icon: const Icon(Icons.mic, size: 18),
                label: const Text('Speak Again'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.terracotta),
                  foregroundColor: AppColors.terracotta,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                ),
              ),
            ),
          // Product Name
          _buildLabel('Product Name'),
          _buildTextField(_nameCtrl, 'e.g. Handcrafted Wooden Jewelry Box'),
          const SizedBox(height: 16),
          // Description
          _buildLabel('Description'),
          _buildTextField(
            _descCtrl,
            'Describe your product...',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          // Category
          _buildLabel('Category'),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          // Price
          _buildLabel('Price (\u20B9)'),
          _buildTextField(_priceCtrl, '0', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          // Material
          _buildLabel('Material'),
          _buildTextField(_materialCtrl, 'e.g. Sheesham Wood'),
          const SizedBox(height: 16),
          // Making Time
          _buildLabel('Making Time'),
          _buildTextField(_makingTimeCtrl, 'e.g. 5 days'),
          const SizedBox(height: 16),
          // Tags
          _buildLabel('Tags (comma separated)'),
          _buildTextField(_tagsCtrl, 'e.g. handmade, traditional, gift'),
          const SizedBox(height: 20),
          // Product Images
          _buildLabel('Product Images'),
          const SizedBox(height: 8),
          _buildImagePicker(),
          const SizedBox(height: 32),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      setState(() => _step = _FlowStep.voice),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.terracotta),
                    foregroundColor: AppColors.terracotta,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      setState(() => _step = _FlowStep.preview),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: AppColors.cream,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Preview'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STEP 3: PREVIEW ─────────────────────────────────────────────────────

  Widget _buildPreviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg).add(
        const EdgeInsets.only(bottom: 100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product images
          if (_images.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.warmBeige.withValues(alpha: 0.3),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusLG),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusLG),
                child: Image.asset(
                  _images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image,
                        size: 64, color: AppColors.brown),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.warmBeige.withValues(alpha: 0.3),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusLG),
              ),
              child: const Center(
                child: Icon(Icons.image,
                    size: 64, color: AppColors.brown),
              ),
            ),
          const SizedBox(height: 20),
          // Product name
          Text(
            _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Untitled Product',
            style: AppTextStyles.headlineMedium
                .copyWith(color: AppColors.brown),
          ),
          const SizedBox(height: 8),
          // Price
          if (_priceCtrl.text.isNotEmpty)
            Text(
              '\u20B9${_priceCtrl.text}',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.terracotta,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 12),
          // Tags row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_categoryCtrl.text.isNotEmpty)
                _buildPreviewTag(_categoryCtrl.text, AppColors.oliveGreen),
              if (_materialCtrl.text.isNotEmpty)
                _buildPreviewTag(_materialCtrl.text, AppColors.mustardGold),
              if (_makingTimeCtrl.text.isNotEmpty)
                _buildPreviewTag(
                    _makingTimeCtrl.text, AppColors.terracotta),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          if (_descCtrl.text.isNotEmpty) ...[
            Text(
              'Description',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.brown),
            ),
            const SizedBox(height: 6),
            Text(
              _descCtrl.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      setState(() => _step = _FlowStep.form),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.terracotta),
                    foregroundColor: AppColors.terracotta,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD),
                    ),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _publishProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: AppColors.cream,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Publish Product'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SHARED WIDGETS ───────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.brown),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide:
              const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
      hint: Text('Select category',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          )),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide:
              const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
      ),
      items: _categories
          .map((c) => DropdownMenuItem(value: c.toLowerCase(), child: Text(c)))
          .toList(),
      onChanged: (val) {
        setState(() {
          _selectedCategory = val ?? '';
          _categoryCtrl.text =
              val != null ? val[0].toUpperCase() + val.substring(1) : '';
        });
      },
    );
  }

  Widget _buildImagePicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._images.asMap().entries.map((e) => Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSM),
                    color: AppColors.warmBeige.withValues(alpha: 0.3),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSM),
                    child: Image.asset(e.value, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, color: AppColors.brown)),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _images.removeAt(e.key)),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )),
        GestureDetector(
          onTap: _addImage,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              border: Border.all(
                  color: AppColors.divider, style: BorderStyle.solid),
              color: AppColors.surface,
            ),
            child: const Icon(Icons.add_a_photo_outlined,
                size: 24, color: AppColors.brown),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
