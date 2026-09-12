import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/api_config.dart';
import '../../../core/services/deepgram_stream_service.dart';
import '../models/product_draft.dart';
import 'voice_step2_quantity_screen.dart';

class VoiceStep1DetailsScreen extends StatefulWidget {
  final ProductDraft draft;

  const VoiceStep1DetailsScreen({super.key, required this.draft});

  @override
  State<VoiceStep1DetailsScreen> createState() => _VoiceStep1DetailsScreenState();
}

class _VoiceStep1DetailsScreenState extends State<VoiceStep1DetailsScreen>
    with SingleTickerProviderStateMixin {
  // Mode: true = showing extracted form, false = voice recording mode
  bool _showExtractedForm = false;
  bool _extractionHadData = false; // track whether extraction returned anything useful

  // Recording & Live Caption state
  bool _isRecording = false;
  bool _isExtracting = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  late AnimationController _waveController;
  String _liveCaption = '';
  String? _audioPath;
  String? _errorMessage;

  // Deepgram streaming STT
  final DeepgramStreamService _sttService = DeepgramStreamService();
  late String _selectedLanguage;
  late String _selectedLocaleId;

  // Extracted Form Controllers
  late final TextEditingController _productNameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _materialCtrl;
  late final TextEditingController _craftCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _descriptionCtrl;

  // Manual text input toggle in voice mode
  bool _showManualInput = false;
  final TextEditingController _manualInputCtrl = TextEditingController();

  // DEV debug panel state
  String? _debugTranscript;
  Map<String, dynamic>? _debugExtracted;

  final List<String> _guidingQuestions = [
    'Product ka naam kya hai? (e.g. bamboo ki tokri)',
    'Kis material se bana hai? (mitti, lakdi, pital, silk, bamboo)',
    'Kaunsi kala ya craft hai? (Blue Pottery, Chikankari, etc.)',
    'Rang (color) aur size / weight kya hai?',
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final d = widget.draft;
    _selectedLocaleId = d.voiceLanguage;
    _selectedLanguage = _selectedLocaleId == 'en_IN' ? 'English' : 'Hindi';
    _productNameCtrl = TextEditingController(text: d.productName ?? '');
    _categoryCtrl = TextEditingController(text: d.category ?? '');
    _materialCtrl = TextEditingController(text: d.material ?? '');
    _craftCtrl = TextEditingController(text: d.craft ?? '');
    _colorCtrl = TextEditingController(text: d.color ?? '');
    _sizeCtrl = TextEditingController(text: d.size ?? '');
    _weightCtrl = TextEditingController(text: d.weight ?? '');
    _descriptionCtrl = TextEditingController(text: d.description ?? '');

    // If draft already has product name, show form
    if (d.productName != null && d.productName!.isNotEmpty) {
      _showExtractedForm = true;
      _extractionHadData = true;
    }

  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _waveController.dispose();
    _productNameCtrl.dispose();
    _categoryCtrl.dispose();
    _materialCtrl.dispose();
    _craftCtrl.dispose();
    _colorCtrl.dispose();
    _sizeCtrl.dispose();
    _weightCtrl.dispose();
    _descriptionCtrl.dispose();
    _manualInputCtrl.dispose();
    _sttService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_isExtracting) return;

    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _liveCaption = '';
      _audioPath = null;
      _errorMessage = null;
    });

    _waveController.repeat(reverse: true);
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _recordingSeconds++);
    });

    _sttService.onTranscript = (text, isFinal) {
      if (mounted) setState(() => _liveCaption = text);
    };
    _sttService.onError = (error) {
      debugPrint('[LIVE STT ERROR] $error');
    };
    final langCode = _selectedLocaleId.split('_').first;
    _sttService.start(language: langCode);
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _waveController.stop();

    final sttTranscript = await _sttService.stop();
    if (sttTranscript.isNotEmpty && _liveCaption.isEmpty) {
      _liveCaption = sttTranscript;
    }

    if (mounted) setState(() => _isRecording = false);
    _processExtraction();
  }

  Future<void> _processExtraction() async {
    final spokenText = _liveCaption.trim();
    if (spokenText.isNotEmpty) {
      debugPrint('[Process] Using transcript: "$spokenText"');
      await _extractDetailsFromText(spokenText);
      return;
    }

    if (_audioPath != null) {
      final file = File(_audioPath!);
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;
      debugPrint('[Process] Audio file: $_audioPath, exists=$exists, size=$size bytes');

      if (exists && size > 1000) {
        await _extractFromAudioFile();
        return;
      }
    }

    if (mounted) {
      setState(() {
        _errorMessage = 'No speech detected. Please speak clearly and try again.';
        _isExtracting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please speak clearly about your product, then tap Done.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _extractDetailsFromText(String text) async {
    if (mounted) setState(() => _isExtracting = true);

    debugPrint('[Extract] Sending to backend extract-step1: "${text.substring(0, text.length.clamp(0, 80))}..."');

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/ai/extract-step1');
      debugPrint('[Extract] POST $uri');

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'transcript': text}),
      ).timeout(const Duration(seconds: 20));

      debugPrint('[Extract] HTTP status: ${resp.statusCode}');
      debugPrint('[Extract] Response body: ${resp.body.substring(0, resp.body.length.clamp(0, 500))}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is Map) {
          final extracted = data['data'] as Map<String, dynamic>;
          debugPrint('[Extract] Extracted data: $extracted');
          if (mounted) {
            setState(() {
              _debugTranscript = text;
              _debugExtracted = extracted;
            });
          }
          _populateControllersFromServer(extracted);
          _saveTowardsDraft(text);
          if (mounted) {
            setState(() {
              _isExtracting = false;
              _showExtractedForm = true;
              _extractionHadData = _hasAnyData(extracted);
              _errorMessage = _extractionHadData ? null : 'Extraction returned no data. Please speak more clearly.';
            });
          }
          return;
        } else {
          debugPrint('[Extract] Backend returned success=false or no data: $data');
        }
      }
    } catch (e) {
      debugPrint('[Extract] Backend call failed: $e');
    }

    // Backend failed — show form with whatever we have
    _saveTowardsDraft(text);
    if (mounted) {
      setState(() {
        _isExtracting = false;
        _showExtractedForm = true;
        _extractionHadData = false;
        _errorMessage = 'Could not reach AI. Please check connection and try again, or fill manually.';
      });
    }
  }

  Future<void> _extractFromAudioFile() async {
    if (_audioPath == null) return;
    if (mounted) setState(() => _isExtracting = true);

    final langCode = _selectedLocaleId.split('_').first;

    try {
      final file = File(_audioPath!);
      final bytes = await file.readAsBytes();
      debugPrint('[AudioUpload] File size: ${bytes.length} bytes');

      for (final host in ApiConfig.candidateUrls) {
        try {
          final uri = Uri.parse('$host/api/ai/voice-to-catalog?step=1&language=$langCode');
          debugPrint('[AudioUpload] Trying: $uri');

          final req = http.MultipartRequest('POST', uri);
          req.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'step1_voice.wav',
            contentType: MediaType('audio', 'wav'),
          ));

          final streamed = await req.send().timeout(const Duration(seconds: 30));
          debugPrint('[AudioUpload] HTTP status: ${streamed.statusCode}');

          if (streamed.statusCode == 200) {
            final body = await streamed.stream.bytesToString();
            debugPrint('[AudioUpload] Response: ${body.substring(0, body.length.clamp(0, 600))}');

            final data = jsonDecode(body) as Map<String, dynamic>;
            final success = data['success'] as bool? ?? false;
            final transcript = data['transcript'] as String? ?? '';
            final extracted = data['data'] as Map<String, dynamic>?;

            debugPrint('[AudioUpload] success=$success, transcript="${transcript.substring(0, transcript.length.clamp(0, 100))}"');
            debugPrint('[AudioUpload] extracted=$extracted');

            if (!success) {
              final errorMsg = data['error'] as String? ?? 'Transcription failed';
              if (mounted) {
                setState(() {
                  _isExtracting = false;
                  _errorMessage = errorMsg;
                  _showExtractedForm = true;
                  _extractionHadData = false;
                });
              }
              return;
            }

            if (transcript.isNotEmpty) {
              _liveCaption = transcript;
            }

            if (extracted != null) {
              if (mounted) {
                setState(() {
                  _debugTranscript = transcript;
                  _debugExtracted = extracted;
                });
              }
              _populateControllersFromServer(extracted);
              _saveTowardsDraft(transcript);
              final hadData = _hasAnyData(extracted);
              if (mounted) {
                setState(() {
                  _isExtracting = false;
                  _showExtractedForm = true;
                  _extractionHadData = hadData;
                  _errorMessage = hadData ? null : 'Speech was heard but details could not be extracted. Please edit manually.';
                });
              }
            } else {
              _saveTowardsDraft(transcript);
              if (mounted) {
                setState(() {
                  _isExtracting = false;
                  _showExtractedForm = true;
                  _extractionHadData = false;
                  _errorMessage = 'No product details extracted. Please fill in manually.';
                });
              }
            }
            return;
          }
        } catch (e) {
          debugPrint('[AudioUpload] Host $host failed: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('[AudioUpload] Fatal error: $e');
    }

    // All hosts failed
    if (mounted) {
      setState(() {
        _isExtracting = false;
        _showExtractedForm = true;
        _extractionHadData = false;
        _errorMessage = 'Could not connect to AI server. Please fill in details manually.';
      });
    }
  }

  /// Populate controllers from server data.
  /// Server data always wins — overwrite whatever was there before.
  void _populateControllersFromServer(Map<String, dynamic> data) {
    debugPrint('[Populate] Populating controllers from: $data');

    final name = _str(data['product_name']);
    final cat = _str(data['category']);
    final mat = _str(data['material']);
    final craft = _str(data['craft']);
    final color = _str(data['color']);
    final size = _str(data['size']);
    final weight = _str(data['weight']);
    final desc = _str(data['description']);

    // Use setState to trigger rebuild after controller text changes
    if (mounted) {
      setState(() {
        if (name != null) _productNameCtrl.text = name;
        if (cat != null) _categoryCtrl.text = cat;
        if (mat != null) _materialCtrl.text = mat;
        if (craft != null) _craftCtrl.text = craft;
        if (color != null) _colorCtrl.text = color;
        if (size != null) _sizeCtrl.text = size;
        if (weight != null) _weightCtrl.text = weight;
        if (desc != null) _descriptionCtrl.text = desc;
      });
    }

    debugPrint('[Populate] product_name="${_productNameCtrl.text}" category="${_categoryCtrl.text}" material="${_materialCtrl.text}"');
  }

  void _saveTowardsDraft(String transcript) {
    widget.draft.voiceTranscript = transcript;
  }

  bool _hasAnyData(Map<String, dynamic> data) {
    return ['product_name', 'category', 'material', 'craft', 'color', 'size', 'weight', 'description']
        .any((k) => _str(data[k]) != null);
  }

  String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  void _saveAndProceedToStep2() {
    final d = widget.draft;
    d.productName = _productNameCtrl.text.trim().isNotEmpty ? _productNameCtrl.text.trim() : d.productName;
    d.category = _categoryCtrl.text.trim().isNotEmpty ? _categoryCtrl.text.trim() : d.category;
    d.material = _materialCtrl.text.trim().isNotEmpty ? _materialCtrl.text.trim() : d.material;
    d.craft = _craftCtrl.text.trim().isNotEmpty ? _craftCtrl.text.trim() : d.craft;
    d.color = _colorCtrl.text.trim().isNotEmpty ? _colorCtrl.text.trim() : d.color;
    d.size = _sizeCtrl.text.trim().isNotEmpty ? _sizeCtrl.text.trim() : d.size;
    d.weight = _weightCtrl.text.trim().isNotEmpty ? _weightCtrl.text.trim() : d.weight;
    d.description = _descriptionCtrl.text.trim().isNotEmpty ? _descriptionCtrl.text.trim() : d.description;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceStep2QuantityScreen(draft: widget.draft),
      ),
    );
  }

  void _showLanguageSheet() {
    final languages = [
      {'name': 'Hindi', 'locale': 'hi_IN'},
      {'name': 'English', 'locale': 'en_IN'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppDimensions.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: AppDimensions.md),
              Text('Select Voice Language', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppDimensions.sm),
              ...languages.map((lang) {
                final isSelected = _selectedLocaleId == lang['locale'];
                return ListTile(
                  title: Text(
                    lang['name']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.terracotta : AppColors.charcoal,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.terracotta) : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = lang['name']!.split(' ').first;
                      _selectedLocaleId = lang['locale']!;
        widget.draft.voiceLanguage = lang['locale']!;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        );
      },
    );
  }

  String get _timerText {
    final m = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_recordingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

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
        title: Column(
          children: [
            Text(
              'Step 1 of 3: Product Details',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
            ),
            const SizedBox(height: 2),
            Text(
              'उत्पाद का विवरण',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.cream.withValues(alpha: 0.8), fontSize: 11),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepProgressHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: _showExtractedForm ? _buildExtractedFormView() : _buildVoiceInputView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgressHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepDot(1, 'Details', true, true),
              _buildStepLine(false),
              _buildStepDot(2, 'Quantity', false, false),
              _buildStepLine(false),
              _buildStepDot(3, 'Origin Story', false, false),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              _buildProductThumbnail(),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showExtractedForm ? 'Review Product Details' : 'Tell About Your Product',
                      style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _showExtractedForm
                          ? 'AI has extracted details. You can edit before saving.'
                          : 'Speak naturally — HastKala AI extracts all details live!',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
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

  Widget _buildStepDot(int step, String label, bool isActive, bool isCurrent) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.terracotta : (isActive ? AppColors.oliveGreen : AppColors.borderLight),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? AppColors.terracotta : AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Container(
      width: 30,
      height: 2,
      color: isDone ? AppColors.oliveGreen : AppColors.borderLight,
      margin: const EdgeInsets.only(bottom: 14),
    );
  }

  Widget _buildProductThumbnail() {
    final path = widget.draft.imagePath;
    if (path == null) return const SizedBox.shrink();

    Widget img;
    if (widget.draft.isBase64Image) {
      final b64 = path.contains(',') ? path.split(',').last : path;
      img = Image.memory(base64Decode(b64), fit: BoxFit.cover);
    } else {
      img = Image.file(File(path), fit: BoxFit.cover);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        child: img,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VOICE INPUT VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildVoiceInputView() {
    return Column(
      children: [
        _buildGuidingQuestionsCard(),
        const SizedBox(height: AppDimensions.lg),
        _buildLanguageChip(),
        const SizedBox(height: AppDimensions.xl),
        if (_isExtracting) ...[
          _buildExtractingIndicator(),
        ] else if (_isRecording) ...[
          _buildLiveCaptionActiveView(),
        ] else ...[
          _buildMicButton(),
          const SizedBox(height: AppDimensions.xl),
          if (_liveCaption.isNotEmpty) _buildCaptionPreview(),
          const SizedBox(height: AppDimensions.md),
          _buildManualToggle(),
          if (_showManualInput) ...[
            const SizedBox(height: AppDimensions.md),
            _buildManualInputSection(),
          ],
        ],
      ],
    );
  }

  Widget _buildGuidingQuestionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, size: 18, color: AppColors.terracotta),
              const SizedBox(width: AppDimensions.sm),
              Text(
                'Aap yeh baatein bol sakte hain:',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          ..._guidingQuestions.map((q) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(q, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal, fontSize: 13)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLanguageChip() {
    return GestureDetector(
      onTap: _showLanguageSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 16, color: AppColors.terracotta),
            const SizedBox(width: 6),
            Text(
              'Voice Language: $_selectedLanguage',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.terracotta),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _startRecording,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.4), width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.terracotta.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.mic, color: AppColors.terracotta, size: 44),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          'Tap to Speak',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Bolna shuru karein — bolo aur AI extract karega',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLiveCaptionActiveView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(
              'LIVE LISTENING  $_timerText',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        _buildWaveform(),
        const SizedBox(height: AppDimensions.lg),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 140),
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: AppColors.terracotta, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.terracotta.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.record_voice_over_rounded, size: 16, color: AppColors.terracotta),
                  const SizedBox(width: 6),
                  Text(
                    'Live Captions:',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                _liveCaption.isNotEmpty
                    ? _liveCaption
                    : 'Listening to your voice... speak about your product now...',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: _liveCaption.isNotEmpty ? AppColors.charcoal : AppColors.textSecondary,
                  height: 1.45,
                  fontStyle: _liveCaption.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _stopRecording,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 20),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'Done Speaking — Extract Details',
                  style: AppTextStyles.buttonMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(24, (i) {
            final h = (8 + (i % 5) * 8) * (0.4 + _waveController.value * 0.6);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.2),
              width: 3.5,
              height: h,
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.5 + _waveController.value * 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildExtractingIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(color: AppColors.brown.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(AppColors.terracotta)),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            'HastKala AI Extracting...',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Identifying product name, category, material & craft...',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last Spoken:', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(_liveCaption, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal)),
        ],
      ),
    );
  }

  Widget _buildManualToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showManualInput = !_showManualInput),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showManualInput ? Icons.keyboard_hide : Icons.keyboard,
              size: 18,
              color: AppColors.terracotta,
            ),
            const SizedBox(width: 6),
            Text(
              _showManualInput ? 'Hide typing input' : 'Or type product details manually',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputSection() {
    return Column(
      children: [
        TextField(
          controller: _manualInputCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g. Main bamboo ki tokri banata hoon. Brown rang ki hai. Size 12 inch hai.',
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final text = _manualInputCtrl.text.trim();
              if (text.isNotEmpty) {
                _extractDetailsFromText(text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
            ),
            child: const Text('Extract from Typed Text'),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXTRACTED FORM VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildExtractedFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status banner
        if (_errorMessage != null)
          _buildErrorBanner()
        else if (_extractionHadData)
          _buildSuccessBanner()
        else
          _buildWarningBanner(),

        const SizedBox(height: AppDimensions.lg),

        // DEV DEBUG PANEL — only in debug mode
        if (kDebugMode && (_debugTranscript != null || _debugExtracted != null))
          _buildDebugPanel(),

        _buildFormField('Product Title / Name', _productNameCtrl, Icons.shopping_bag_outlined, 'e.g. Bamboo Basket, Clay Diya'),
        const SizedBox(height: AppDimensions.md),
        _buildFormField('Category', _categoryCtrl, Icons.category_outlined, 'e.g. Bamboo & Cane, Pottery & Ceramics'),
        const SizedBox(height: AppDimensions.md),
        _buildFormField('Material', _materialCtrl, Icons.texture_outlined, 'e.g. Bamboo, Terracotta Clay, Wood'),
        const SizedBox(height: AppDimensions.md),
        _buildFormField('Craft Technique', _craftCtrl, Icons.handyman_outlined, 'e.g. Blue Pottery, Hand Carved (leave blank if none)'),
        const SizedBox(height: AppDimensions.md),
        _buildFormField('Color(s)', _colorCtrl, Icons.palette_outlined, 'e.g. Brown, Blue & Gold'),
        const SizedBox(height: AppDimensions.md),
        Row(
          children: [
            Expanded(child: _buildFormField('Size / Dimensions', _sizeCtrl, Icons.straighten_outlined, 'e.g. 12 inch')),
            const SizedBox(width: AppDimensions.md),
            Expanded(child: _buildFormField('Weight', _weightCtrl, Icons.scale_outlined, 'e.g. 400 grams')),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        _buildFormField('Description', _descriptionCtrl, Icons.description_outlined, 'Short description of your product'),
        const SizedBox(height: AppDimensions.xxl),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saveAndProceedToStep2,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Save & Continue to Step 2 (Quantity) →',
                  style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
      ],
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.oliveGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.oliveGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.oliveGreen, size: 20),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              'Details extracted! Review or edit below.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.oliveGreen, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _showExtractedForm = false;
              _errorMessage = null;
            }),
            child: const Text('Speak Again', style: TextStyle(color: AppColors.terracotta, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              'Speech heard but no details extracted. Please fill in manually.',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.orange.shade800, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _showExtractedForm = false;
              _errorMessage = null;
            }),
            child: const Text('Try Again', style: TextStyle(color: AppColors.terracotta, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              _errorMessage ?? 'Something went wrong.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _showExtractedForm = false;
              _errorMessage = null;
            }),
            child: const Text('Try Again', style: TextStyle(color: AppColors.terracotta, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  /// DEV-ONLY debug panel — visible only in debug builds
  Widget _buildDebugPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.lg),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🛠 DEV DEBUG — Remove before production',
            style: TextStyle(color: Colors.yellow, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          if (_debugTranscript != null) ...[
            const Text('Transcript:', style: TextStyle(color: Colors.grey, fontSize: 10)),
            Text(
              _debugTranscript!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 6),
          ],
          if (_debugExtracted != null) ...[
            const Text('Extracted:', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ...(_debugExtracted!.entries
                .where((e) => e.value != null && e.value.toString().isNotEmpty && e.value.toString() != 'null')
                .map((e) => Text(
                      '  ${e.key}: ${e.value}',
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                    ))),
          ],
        ],
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.terracotta),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
