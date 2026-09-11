import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/api_config.dart';
import '../../../core/services/fast_catalog_extractor.dart';
import '../models/product_draft.dart';

class TellAboutProductScreen extends StatefulWidget {
  final ProductDraft draft;

  const TellAboutProductScreen({super.key, required this.draft});

  @override
  State<TellAboutProductScreen> createState() => _TellAboutProductScreenState();
}

class _TellAboutProductScreenState extends State<TellAboutProductScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isProcessing = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  late AnimationController _waveController;
  String _transcript = '';
  String? _audioPath;
  String? _processingStatus;
  int _processingStep = 0;
  bool _showManualInput = false;
  final TextEditingController _manualController = TextEditingController();

  // Speech to text
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  String _selectedLanguage = 'Hindi';
  String _selectedLocaleId = 'hi_IN';

  // Audio recording fallback
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderInitialized = false;

  final List<String> _extractionSteps = [
    'Listening to your voice...',
    'Identifying craft, material & style...',
    'Structuring catalog & auto-filling details...',
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _initSpeech();
    _initRecorder();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _waveController.dispose();
    _manualController.dispose();
    try {
      _speech.stop();
      _speech.cancel();
    } catch (_) {}
    if (_recorderInitialized) {
      _recorder.closeRecorder();
    }
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (e) {
          debugPrint('SpeechToText error: ${e.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('SpeechToText status: $status');
          if (status == 'done' || status == 'notListening') {
            if (_isRecording && mounted) {
              _stopRecording();
            }
          }
        },
      );
      if (mounted) {
        setState(() => _speechAvailable = available);
      }
    } catch (e) {
      debugPrint('SpeechToText init error: $e');
    }
  }

  Future<void> _initRecorder() async {
    try {
      await _recorder.openRecorder();
      _recorderInitialized = true;
    } catch (e) {
      debugPrint('Recorder init error: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_isProcessing) return;

    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _transcript = '';
      _audioPath = null;
      _processingStatus = null;
      _processingStep = 0;
    });

    _waveController.repeat(reverse: true);
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() => _recordingSeconds++);
      }
    });

    // 1. Try real-time device speech recognition
    if (_speechAvailable) {
      try {
        await _speech.listen(
          onResult: _onSpeechResult,
          listenOptions: SpeechListenOptions(
            localeId: _selectedLocaleId,
            listenMode: ListenMode.dictation,
            partialResults: true,
            cancelOnError: false,
          ),
        );
      } catch (e) {
        debugPrint('Speech listen error: $e');
      }
    }

    // 2. Parallel audio recording fallback
    try {
      if (!_recorderInitialized) {
        await _initRecorder();
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/hastkala_voice.mp4';
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacMP4,
        bitRate: 128000,
        sampleRate: 44100,
      );
      _audioPath = path;
    } catch (e) {
      debugPrint('Audio recording error: $e');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        _transcript = result.recognizedWords;
      });
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _waveController.stop();

    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}

    try {
      if (_recorder.isRecording) {
        final path = await _recorder.stopRecorder();
        if (path != null) _audioPath = path;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }

    // Instantly extract details! ("fatak se bole, fatak se extract ho")
    _autoExtractAndProceed();
  }

  Future<void> _autoExtractAndProceed() async {
    final spokenText = _transcript.trim();

    // If live speech gave words: extract directly (zero latency!)
    if (spokenText.isNotEmpty) {
      await _extractAndPopulate(spokenText);
      return;
    }

    // If live speech was empty but audio file was recorded, send to backend
    if (_audioPath != null) {
      await _transcribeAndExtractFromAudio();
      return;
    }

    // If both empty, prompt user to speak or type
    if (mounted) {
      setState(() {
        _processingStatus = 'Please speak or type details about your product.';
      });
    }
  }

  Future<void> _extractAndPopulate(String text) async {
    setState(() {
      _isProcessing = true;
      _processingStep = 0;
      _processingStatus = _extractionSteps[0];
    });

    // Step 1: Ultra-fast on-device instant extraction (runs in 2ms!)
    final localExtracted = FastCatalogExtractor.extract(text);

    if (mounted) {
      setState(() {
        _processingStep = 1;
        _processingStatus = _extractionSteps[1];
      });
    }

    // Step 2: Attempt fast backend enrichment in parallel with a strict 2.5s timeout.
    // If backend is unreachable or slow, local extraction is 100% complete and used!
    Map<String, dynamic> finalExtracted = Map<String, dynamic>.from(localExtracted);

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/ai/extract-product-details');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'transcript': text}),
      ).timeout(const Duration(milliseconds: 2500));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is Map) {
          final serverMap = data['data'] as Map<String, dynamic>;
          serverMap.forEach((k, v) {
            if (v != null && v.toString().trim().isNotEmpty) {
              finalExtracted[k] = v;
            }
          });
        }
      }
    } catch (_) {
      // Backend timed out or connection error: seamlessly use instant local extraction!
      // This eliminates ANY connection error popup for the user!
    }

    if (mounted) {
      setState(() {
        _processingStep = 2;
        _processingStatus = _extractionSteps[2];
      });
    }

    // Populate ProductDraft
    widget.draft.voiceTranscript = text;
    widget.draft.productName = finalExtracted['product_name'] as String? ?? widget.draft.productName;
    widget.draft.category = finalExtracted['category'] as String? ?? widget.draft.category;
    widget.draft.material = finalExtracted['material'] as String? ?? widget.draft.material;
    widget.draft.craft = finalExtracted['craft'] as String? ?? widget.draft.craft;
    widget.draft.color = finalExtracted['color'] as String? ?? widget.draft.color;
    widget.draft.size = finalExtracted['size'] as String? ?? widget.draft.size;
    widget.draft.weight = finalExtracted['weight'] as String? ?? widget.draft.weight;
    if (finalExtracted['quantity'] != null) {
      widget.draft.quantity = int.tryParse(finalExtracted['quantity'].toString());
    }
    widget.draft.makingTime = finalExtracted['making_time'] as String? ?? widget.draft.makingTime;
    widget.draft.makingProcess = finalExtracted['making_process'] as String? ?? widget.draft.makingProcess;
    widget.draft.location = finalExtracted['location'] as String? ?? widget.draft.location;
    if (finalExtracted['price'] != null) {
      widget.draft.price = int.tryParse(finalExtracted['price'].toString());
    }
    widget.draft.craftStory = finalExtracted['craft_story'] as String? ?? widget.draft.craftStory;

    // Small delay (~500ms) so user perceives the high-tech AI auto-fill transition
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      Navigator.pushNamed(
        context,
        '/review-details',
        arguments: widget.draft,
      );
    }
  }

  Future<void> _transcribeAndExtractFromAudio() async {
    if (_audioPath == null) return;

    setState(() {
      _isProcessing = true;
      _processingStep = 0;
      _processingStatus = 'Sending audio to HastKala AI...';
    });

    try {
      final file = File(_audioPath!);
      final bytes = await file.readAsBytes();

      http.StreamedResponse? response;

      // Try candidate URLs with quick timeout
      for (final candidate in ApiConfig.candidateUrls) {
        try {
          final uri = Uri.parse('$candidate/api/ai/voice-to-catalog');
          final req = http.MultipartRequest('POST', uri);
          req.files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: 'voice.m4a',
              contentType: MediaType('audio', 'mp4'),
            ),
          );
          response = await req.send().timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            break;
          }
        } catch (_) {
          continue;
        }
      }

      if (response != null && response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = jsonDecode(body);
        if (data['success'] == true) {
          final transcript = data['transcript'] as String? ?? '';
          final extracted = data['data'] as Map<String, dynamic>?;

          widget.draft.voiceTranscript = transcript;
          if (extracted != null) {
            widget.draft.productName = extracted['product_name'] as String?;
            widget.draft.category = extracted['category'] as String?;
            widget.draft.material = extracted['material'] as String?;
            widget.draft.craft = extracted['craft'] as String?;
            widget.draft.color = extracted['color'] as String?;
            widget.draft.size = extracted['size'] as String?;
            widget.draft.weight = extracted['weight'] as String?;
            if (extracted['quantity'] != null) {
              widget.draft.quantity = int.tryParse(extracted['quantity'].toString());
            }
            widget.draft.makingTime = extracted['making_time'] as String?;
            widget.draft.makingProcess = extracted['making_process'] as String?;
            widget.draft.location = extracted['location'] as String?;
            if (extracted['price'] != null) {
              widget.draft.price = int.tryParse(extracted['price'].toString());
            }
            widget.draft.craftStory = extracted['craft_story'] as String?;
          }

          if (mounted) {
            setState(() => _isProcessing = false);
            Navigator.pushNamed(context, '/review-details', arguments: widget.draft);
          }
          return;
        }
      }
    } catch (_) {}

    // Fallback: If network failed, show manual typing option gracefully
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _showManualInput = true;
        _processingStatus = 'Could not reach server. You can type details below to extract instantly!';
      });
    }
  }

  void _onManualExtract() {
    final text = _manualController.text.trim();
    if (text.isEmpty) return;
    _extractAndPopulate(text);
  }

  void _showLanguageSheet() {
    final languages = [
      {'name': 'Hindi (हिन्दी)', 'locale': 'hi_IN'},
      {'name': 'English (India)', 'locale': 'en_IN'},
      {'name': 'Marathi (मराठी)', 'locale': 'mr_IN'},
      {'name': 'Gujarati (ગુજરાતી)', 'locale': 'gu_IN'},
      {'name': 'Bengali (বাংলা)', 'locale': 'bn_IN'},
      {'name': 'Tamil (தமிழ்)', 'locale': 'ta_IN'},
      {'name': 'Telugu (తెలుగు)', 'locale': 'te_IN'},
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
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text('Select Voice Language', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppDimensions.md),
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
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: AppDimensions.lg),
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
        title: Text(
          'Tell About Product',
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
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: AppDimensions.xl),
                  _buildHeading(),
                  const SizedBox(height: AppDimensions.md),
                  _buildLanguageChip(),
                  const SizedBox(height: AppDimensions.xl),
                  if (_isProcessing) ...[
                    _buildProcessingState(),
                  ] else if (_isRecording) ...[
                    _buildRecordingState(),
                  ] else ...[
                    _buildMicButton(),
                    const SizedBox(height: AppDimensions.xl),
                    if (_transcript.isNotEmpty) _buildTranscriptCard(),
                    if (_processingStatus != null && !_isProcessing) _buildStatusAlert(),
                    const SizedBox(height: AppDimensions.md),
                    _buildExampleText(),
                    const SizedBox(height: AppDimensions.lg),
                    _buildManualToggle(),
                    if (_showManualInput) ...[
                      const SizedBox(height: AppDimensions.md),
                      _buildManualInputField(),
                    ],
                  ],
                ],
              ),
            ),
          ),
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
              'Language: $_selectedLanguage',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.terracotta),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final path = widget.draft.imagePath;
    if (path == null) return const SizedBox.shrink();

    Widget image;
    if (widget.draft.isBase64Image) {
      image = Image.memory(
        _decodeBase64(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    } else {
      image = Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }

    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            child: SizedBox(width: double.infinity, height: 120, child: image),
          ),
          if (widget.draft.useEnhanced)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.oliveGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'AI Enhanced',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.warmBeige,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 40, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildHeading() {
    return Column(
      children: [
        Text(
          'Tell us about your product',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.charcoal),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          'Apni bhasha mein bolkar batayein — HastKala AI turant extract karega',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
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
              color: AppColors.terracotta.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.terracotta.withValues(alpha: 0.4),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.mic,
              color: AppColors.terracotta,
              size: 42,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          'Tap to Speak',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRecordingState() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.error, width: 3),
          ),
          child: const Icon(Icons.mic, color: AppColors.error, size: 42),
        ),
        const SizedBox(height: AppDimensions.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(
              'Listening  $_timerText',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        _buildWaveform(),
        const SizedBox(height: AppDimensions.lg),
        if (_transcript.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.3)),
            ),
            child: Text(
              _transcript,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.charcoal, height: 1.4),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
        ],
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.terracotta,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: AppColors.terracotta.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'Done Speaking — Auto Fill Details',
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
          children: List.generate(20, (i) {
            final height = (10 + (i % 4) * 8) * (0.5 + _waveController.value * 0.5);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3.5,
              height: height,
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

  Widget _buildProcessingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation(AppColors.terracotta),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            _processingStatus ?? 'HastKala AI Extracting...',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.lg),
          ...List.generate(_extractionSteps.length, (index) {
            final isDone = index < _processingStep;
            final isCurrent = index == _processingStep;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    isDone
                        ? Icons.check_circle
                        : isCurrent
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                    size: 18,
                    color: isDone
                        ? AppColors.oliveGreen
                        : isCurrent
                            ? AppColors.terracotta
                            : AppColors.divider,
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Text(
                      _extractionSteps[index],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDone
                            ? AppColors.oliveGreen
                            : isCurrent
                                ? AppColors.charcoal
                                : AppColors.textSecondary,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
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

  Widget _buildTranscriptCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: AppColors.oliveGreen),
              const SizedBox(width: 6),
              Text(
                'Understood Voice',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.oliveGreen, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            _transcript,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAlert() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Text(
        _processingStatus!,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.brown),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildManualToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showManualInput = !_showManualInput),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showManualInput ? Icons.keyboard_arrow_up : Icons.edit_note,
            size: 18,
            color: AppColors.terracotta,
          ),
          const SizedBox(width: 6),
          Text(
            _showManualInput ? 'Hide manual typing' : 'Prefer typing? Type details here',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputField() {
    return Column(
      children: [
        TextField(
          controller: _manualController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g. Ye mitti ka decorative pot hai, 10 inch size, price 850 rupaye...',
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onManualExtract,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
            ),
            child: const Text('Extract & Auto-Fill Details'),
          ),
        ),
      ],
    );
  }

  Widget _buildExampleText() {
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
          Text(
            'Tip: Bolte waqt ye cheezein bata sakte hain:',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.brown, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '• Product ka naam (jaise: matka, vase, saree)\n• Material (mitti, lakdi, silk, brass)\n• Banane ka tarika aur rang (hand painted, blue)\n• Size aur Keemat (jaise: 10 inch, 850 rupaye)',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  static Uint8List _decodeBase64(String data) {
    final base64Str = data.contains(',') ? data.split(',').last : data;
    return base64Decode(base64Str);
  }
}
