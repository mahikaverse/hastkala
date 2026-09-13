import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/api_config.dart';
import '../../../core/services/deepgram_stream_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/widgets/voice_mute_button.dart';
import '../models/product_draft.dart';
import '../../../../core/localization/language_provider.dart';

class VoiceStep3StoryScreen extends StatefulWidget {
  final ProductDraft draft;

  const VoiceStep3StoryScreen({super.key, required this.draft});

  @override
  State<VoiceStep3StoryScreen> createState() => _VoiceStep3StoryScreenState();
}

class _VoiceStep3StoryScreenState extends State<VoiceStep3StoryScreen>
    with SingleTickerProviderStateMixin {
  // Mode: true = showing extracted form, false = voice recording mode
  bool _showExtractedForm = false;

  // Recording & Live Caption state
  bool _isRecording = false;
  bool _isExtracting = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  late AnimationController _waveController;
  String _liveCaption = '';
  String? _audioPath;

  // Deepgram streaming STT
  final DeepgramStreamService _sttService = DeepgramStreamService();
  late String _selectedLanguage;
  late String _selectedLocaleId;

  // Extracted Form Controllers
  late final TextEditingController _craftStoryCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _artisanIntroCtrl;

  // Manual input toggle
  bool _showManualInput = false;
  final TextEditingController _manualInputCtrl = TextEditingController();

  // TTS
  final TtsService _ttsService = TtsService();
  bool _isTtsSpeaking = false;
  bool _isTtsPaused = false;
  bool _ttsAutoPlayed = false;
  Timer? _ttsAutoPlayTimer;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ttsService.initialize();
    _ttsService.onStateChanged = () {
      if (mounted) {
        setState(() {
          _isTtsSpeaking = _ttsService.isSpeaking;
          _isTtsPaused = _ttsService.isPaused;
        });
      }
    };

    final d = widget.draft;
    _selectedLocaleId = d.voiceLanguage;
    _selectedLanguage = _selectedLocaleId == 'en_IN' ? 'English' : 'Hindi';
    _craftStoryCtrl = TextEditingController(text: d.craftStory ?? '');
    _locationCtrl = TextEditingController(text: d.location ?? '');
    _artisanIntroCtrl = TextEditingController(text: d.artisanIntro ?? '');

    if (d.craftStory != null && d.craftStory!.isNotEmpty) {
      _showExtractedForm = true;
    }

    if (!_showExtractedForm && !_ttsAutoPlayed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoPlayGuidance());
    }
  }

  void _autoPlayGuidance() {
    if (!mounted || _ttsAutoPlayed) return;
    _ttsAutoPlayed = true;
    final lang = LanguageProvider.of(context);
    final langCode = _selectedLocaleId.split('_').first;
    final text = langCode == 'hi' ? lang.t('step3TtsGuidanceHi') : lang.t('step3TtsGuidanceEn');
    _ttsService.speak(text, language: langCode);
  }

  @override
  void dispose() {
    _ttsAutoPlayTimer?.cancel();
    _ttsService.stop();
    _recordingTimer?.cancel();
    _waveController.dispose();
    _ttsService.dispose();
    _craftStoryCtrl.dispose();
    _locationCtrl.dispose();
    _artisanIntroCtrl.dispose();
    _manualInputCtrl.dispose();
    _sttService.dispose();
    super.dispose();
  }

  Future<void> _speakGuidance() async {
    final lang = LanguageProvider.of(context);
    final langCode = _selectedLocaleId.split('_').first;
    final text = langCode == 'hi' ? lang.t('step3TtsGuidanceHi') : lang.t('step3TtsGuidanceEn');
    await _ttsService.speak(text, language: langCode);
  }

  Future<void> _pauseGuidance() async {
    await _ttsService.pause();
  }

  Future<void> _resumeGuidance() async {
    await _ttsService.resume();
  }

  Future<void> _replayGuidance() async {
    await _ttsService.replay();
  }

  Future<void> _stopSpeaking() async {
    await _ttsService.stop();
    if (mounted) setState(() { _isTtsSpeaking = false; _isTtsPaused = false; });
  }

  Future<void> _startRecording() async {
    if (_isExtracting) return;

    // Stop TTS before starting mic
    await _stopSpeaking();
    _ttsAutoPlayTimer?.cancel();

    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _liveCaption = '';
      _audioPath = null;
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
    if (spokenText.isNotEmpty && !spokenText.startsWith('[Audio recording')) {
      debugPrint('[Step3] Using transcript: "$spokenText"');
      await _extractDetails(spokenText);
      return;
    }

    if (_audioPath != null) {
      final file = File(_audioPath!);
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;
      debugPrint('[Step3] Audio file: $_audioPath, exists=$exists, size=$size bytes');

      if (exists && size > 1000) {
        await _extractFromAudioFile();
        return;
      }
    }

    if (mounted) {
      final lang = LanguageProvider.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.t('speakOrTypeStory'))),
      );
    }
  }

  Future<void> _extractDetails(String text) async {
    setState(() => _isExtracting = true);
    debugPrint('[Step3] Sending to /api/ai/extract-step3: "${text.substring(0, text.length.clamp(0, 80))}..."');

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/ai/extract-step3');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'transcript': text}),
      ).timeout(const Duration(seconds: 20));

      debugPrint('[Step3] HTTP status: ${resp.statusCode}');
      debugPrint('[Step3] Response: ${resp.body.substring(0, resp.body.length.clamp(0, 400))}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is Map) {
          final serverData = data['data'] as Map<String, dynamic>;
          debugPrint('[Step3] Extracted: $serverData');
          _populateControllers(serverData);
        }
      }
    } catch (e) {
      debugPrint('[Step3] Backend call failed: $e');
    }

    if (mounted) {
      setState(() {
        _isExtracting = false;
        _showExtractedForm = true;
      });
    }
  }

  Future<void> _extractFromAudioFile() async {
    if (_audioPath == null) return;
    setState(() => _isExtracting = true);

    final langCode = _selectedLocaleId.split('_').first;

    try {
      final file = File(_audioPath!);
      final bytes = await file.readAsBytes();
      debugPrint('[Step3 Audio] Uploading ${bytes.length} bytes');

      for (final host in ApiConfig.candidateUrls) {
        try {
          final uri = Uri.parse('$host/api/ai/voice-to-catalog?step=3&language=$langCode');
          debugPrint('[Step3 Audio] Trying: $uri');

          final req = http.MultipartRequest('POST', uri);
          req.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'step3_voice.wav',
            contentType: MediaType('audio', 'wav'),
          ));
          final streamed = await req.send().timeout(const Duration(seconds: 30));
          debugPrint('[Step3 Audio] HTTP status: ${streamed.statusCode}');

          if (streamed.statusCode == 200) {
            final body = await streamed.stream.bytesToString();
            debugPrint('[Step3 Audio] Response: ${body.substring(0, body.length.clamp(0, 500))}');

            final data = jsonDecode(body) as Map<String, dynamic>;
            final success = data['success'] as bool? ?? false;
            final transcript = data['transcript'] as String? ?? '';
            final extracted = data['data'] as Map<String, dynamic>?;

            debugPrint('[Step3 Audio] success=$success, transcript="${transcript.substring(0, transcript.length.clamp(0, 100))}"');

            if (transcript.isNotEmpty) _liveCaption = transcript;

            if (extracted != null) {
              debugPrint('[Step3 Audio] Extracted: $extracted');
              _populateControllers(extracted);
            }
            if (mounted) {
              setState(() {
                _isExtracting = false;
                _showExtractedForm = true;
              });
            }
            return;
          }
        } catch (e) {
          debugPrint('[Step3 Audio] Host $host failed: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('[Step3 Audio] Fatal error: $e');
    }

    if (mounted) {
      setState(() {
        _isExtracting = false;
        _showExtractedForm = true;
      });
    }
  }

  void _populateControllers(Map<String, dynamic> data) {
    if (data['craft_story'] != null && data['craft_story'].toString().trim().isNotEmpty) {
      _craftStoryCtrl.text = data['craft_story'].toString().trim();
    }
    if (data['location'] != null && data['location'].toString().trim().isNotEmpty) {
      _locationCtrl.text = data['location'].toString().trim();
    }
    if (data['artisan_intro'] != null && data['artisan_intro'].toString().trim().isNotEmpty) {
      _artisanIntroCtrl.text = data['artisan_intro'].toString().trim();
    }
  }

  void _saveAndProceedToPricing() {
    final d = widget.draft;
    d.craftStory = _craftStoryCtrl.text.trim().isNotEmpty ? _craftStoryCtrl.text.trim() : d.craftStory;
    d.location = _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : d.location;
    d.artisanIntro = _artisanIntroCtrl.text.trim().isNotEmpty ? _artisanIntroCtrl.text.trim() : d.artisanIntro;

    Navigator.pushNamed(
      context,
      '/set-price',
      arguments: widget.draft,
    );
  }

  void _showLanguageSheet() {
    final lang = LanguageProvider.of(context);
    final languages = [
      {'name': 'Hindi', 'locale': 'hi_IN'},
      {'name': 'English', 'locale': 'en_IN'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppDimensions.md),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: AppDimensions.md),
              Text(lang.t('selectVoiceLanguage'), style: AppTextStyles.titleMedium),
              const SizedBox(height: AppDimensions.sm),
              ...languages.map((lang) {
                final isSelected = _selectedLocaleId == lang['locale'];
                return ListTile(
                  title: Text(lang['name']!, style: AppTextStyles.bodyMedium.copyWith(color: isSelected ? AppColors.terracotta : AppColors.charcoal)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.terracotta) : null,
                  onTap: () async {
                    await _stopSpeaking();
                    _ttsAutoPlayTimer?.cancel();
                    if (!ctx.mounted) return;
                    setState(() {
                      _selectedLanguage = lang['name']!.split(' ').first;
                      _selectedLocaleId = lang['locale']!;
                      widget.draft.voiceLanguage = lang['locale']!;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
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
        title: Column(
          children: [
            Text(lang.t('step3Title'), style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
            const SizedBox(height: 2),
            Text('विरासत और कहानी', style: AppTextStyles.bodySmall.copyWith(color: AppColors.cream.withValues(alpha: 0.8), fontSize: 11)),
          ],
        ),
        centerTitle: true,
        actions: [
          VoiceMuteButton(
            color: AppColors.cream,
            onReplay: _speakGuidance,
          ),
          const SizedBox(width: 8),
        ],
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
    final lang = LanguageProvider.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepDot(1, lang.t('details'), true, false),
              _buildStepLine(true),
              _buildStepDot(2, lang.t('quantity'), true, false),
              _buildStepLine(true),
              _buildStepDot(3, lang.t('originStory'), true, true),
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
                      widget.draft.productName ?? lang.t('productFallback'),
                      style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _showExtractedForm
                          ? lang.t('reviewStory')
                          : lang.t('kahaniBatayein'),
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
              child: isCurrent
                  ? Text('$step', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
                  : (isActive
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : Text('$step', style: const TextStyle(color: Colors.white, fontSize: 11))),
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(AppDimensions.radiusSM), child: img),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VOICE INPUT VIEW (GPT Live Caption)
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
    final lang = LanguageProvider.of(context);

    String mainLabel;
    IconData mainIcon;
    VoidCallback? mainOnTap;

    if (_isTtsSpeaking) {
      mainLabel = lang.t('pause');
      mainIcon = Icons.pause_rounded;
      mainOnTap = _pauseGuidance;
    } else if (_isTtsPaused) {
      mainLabel = lang.t('resume');
      mainIcon = Icons.play_arrow_rounded;
      mainOnTap = _resumeGuidance;
    } else {
      mainLabel = lang.t('listen');
      mainIcon = Icons.volume_up_rounded;
      mainOnTap = _speakGuidance;
    }

    final replayLabel = lang.t('again');

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
              const Icon(Icons.auto_stories_rounded, size: 18, color: AppColors.terracotta),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  lang.t('youCanSpeak'),
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: mainOnTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_isTtsSpeaking || _isTtsPaused)
                        ? AppColors.terracotta.withValues(alpha: 0.15)
                        : AppColors.terracotta,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mainIcon,
                        size: 16,
                        color: (_isTtsSpeaking || _isTtsPaused) ? AppColors.terracotta : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mainLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: (_isTtsSpeaking || _isTtsPaused) ? AppColors.terracotta : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isTtsSpeaking || _isTtsPaused) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _replayGuidance,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.replay_rounded, size: 14, color: AppColors.brown),
                        const SizedBox(width: 3),
                        Text(
                          replayLabel,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brown),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          ...[lang.t('step3GuidingQ1'), lang.t('step3GuidingQ2'), lang.t('step3GuidingQ3'), lang.t('step3GuidingQ4')].map((q) => Padding(
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
    final lang = LanguageProvider.of(context);
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
            Text('${lang.t('voiceLanguage')}: $_selectedLanguage', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.terracotta),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    final lang = LanguageProvider.of(context);
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
                BoxShadow(color: AppColors.terracotta.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.mic, color: AppColors.terracotta, size: 44),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Text(lang.t('tapToSpeakStory'), style: AppTextStyles.titleMedium.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(lang.t('kahaniBolein'), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildLiveCaptionActiveView() {
    final lang = LanguageProvider.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
            const SizedBox(width: AppDimensions.sm),
            Text(
              '${lang.t('liveListening')}  $_timerText',
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        _buildWaveform(),
        const SizedBox(height: AppDimensions.lg),

        // Live Caption Bubble
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 140),
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: AppColors.terracotta, width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.terracotta.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.record_voice_over_rounded, size: 16, color: AppColors.terracotta),
                  const SizedBox(width: 6),
                  Text(lang.t('liveCaptions'), style: AppTextStyles.labelSmall.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                _liveCaption.isNotEmpty
                    ? _liveCaption
                    : lang.t('listeningToVoiceDetails'),
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
                Text(lang.t('doneSpeakingGenerate'), style: AppTextStyles.buttonMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final lang = LanguageProvider.of(context);
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
          Text(lang.t('aiCraftingStory'), style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppDimensions.xs),
          Text(lang.t('writingStory'), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCaptionPreview() {
    final lang = LanguageProvider.of(context);
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
          Text(lang.t('lastSpoken'), style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(_liveCaption, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal)),
        ],
      ),
    );
  }

  Widget _buildManualToggle() {
    final lang = LanguageProvider.of(context);
    return GestureDetector(
      onTap: () => setState(() => _showManualInput = !_showManualInput),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_showManualInput ? Icons.keyboard_hide : Icons.keyboard, size: 18, color: AppColors.terracotta),
            const SizedBox(width: 6),
            Text(
              _showManualInput ? lang.t('hideTypingInput') : lang.t('orTypeStory'),
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputSection() {
    final lang = LanguageProvider.of(context);
    return Column(
      children: [
        TextField(
          controller: _manualInputCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: lang.t('hintStory'),
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
              if (text.isNotEmpty) _extractDetails(text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
            ),
            child: Text(lang.t('extractFromTyped')),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXTRACTED FORM VIEW (Editable Form for Step 3)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildExtractedFormView() {
    final lang = LanguageProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                  lang.t('storyCrafted'),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.oliveGreen, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showExtractedForm = false),
                child: Text(lang.t('speakAgain'), style: TextStyle(color: AppColors.terracotta, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.lg),

        _buildFormField(lang.t('craftOriginHeritage'), _craftStoryCtrl, Icons.auto_stories_outlined, lang.t('hintStory'), maxLines: 4),
        const SizedBox(height: AppDimensions.md),
        _buildFormField(lang.t('artisanLocation'), _locationCtrl, Icons.location_on_outlined, lang.t('hintLocation')),
        const SizedBox(height: AppDimensions.md),
        _buildFormField(lang.t('artisanHeritage'), _artisanIntroCtrl, Icons.person_pin_outlined, lang.t('hintHeritage'), maxLines: 2),
        const SizedBox(height: AppDimensions.xxl),

        // Save & Proceed to Pricing Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saveAndProceedToPricing,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.currency_rupee, size: 20),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  lang.t('saveAndProceedPricing'),
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

  Widget _buildFormField(String label, TextEditingController controller, IconData icon, String hint, {int maxLines = 1}) {
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
          maxLines: maxLines,
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
