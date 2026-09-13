import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/artisan_profile_service.dart';
import '../../../../core/services/auth_service.dart';
import 'edit_profile_screen.dart';

class ArtisanProfileNewScreen extends StatefulWidget {
  const ArtisanProfileNewScreen({super.key});

  @override
  State<ArtisanProfileNewScreen> createState() => _ArtisanProfileNewScreenState();
}

class _ArtisanProfileNewScreenState extends State<ArtisanProfileNewScreen>
    with SingleTickerProviderStateMixin {
  final ArtisanProfileService _profileService = ArtisanProfileService();

  ArtisanProfile? _profile;
  bool _isLoading = true;
  bool _isSavingStory = false;
  bool _isUploadingPhoto = false;
  bool _isPolishingStory = false;

  // Story editing
  final TextEditingController _storyCtrl = TextEditingController();

  // Voice recording & Speech-to-text
  final FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _recorderReady = false;
  bool _speechReady = false;
  bool _isRecording = false;
  bool _isTranscribing = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _recordedAudioPath;

  // Pulse animation for recording mic
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initAudio();
    _loadProfile();
  }

  Future<void> _initAudio() async {
    try {
      await _soundRecorder.openRecorder();
      _recorderReady = true;
    } catch (e) {
      debugPrint('Recorder open error: $e');
    }

    try {
      _speechReady = await _speech.initialize(
        onError: (e) => debugPrint('STT error: ${e.errorMsg}'),
        onStatus: (status) {
          if ((status == 'done' || status == 'notListening') && _isRecording && mounted) {
            _stopRecording();
          }
        },
      );
    } catch (e) {
      debugPrint('Speech init error: $e');
    }
  }

  Future<void> _loadProfile() async {
    final p = await _profileService.getProfile();
    if (mounted) {
      setState(() {
        _profile = p;
        _storyCtrl.text = p?.craftStory ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _pulseController.dispose();
    _storyCtrl.dispose();
    if (_recorderReady) {
      _soundRecorder.closeRecorder();
    }
    try {
      _speech.stop();
      _speech.cancel();
    } catch (_) {}
    super.dispose();
  }

  // ─── AVATAR PICKER & DB UPLOAD ─────────────────────────────────────────────

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.brown),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.terracotta),
                ),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.terracotta),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 800);
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);
    final uploadedUrl = await _profileService.uploadAvatar(File(picked.path));

    if (mounted) {
      setState(() {
        _isUploadingPhoto = false;
        if (uploadedUrl != null && _profile != null) {
          _profile = _profile!.copyWith(avatarUrl: uploadedUrl);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated in database!'),
          backgroundColor: AppColors.oliveGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── VOICE RECORDING & TRANSCRIPTION ───────────────────────────────────────

  Future<void> _startRecording() async {
    try {
      final dir = await getTemporaryDirectory();
      _recordedAudioPath = '${dir.path}/artisan_story_${DateTime.now().millisecondsSinceEpoch}.wav';

      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _pulseController.repeat(reverse: true);
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordingSeconds++);
      });

      // 1. Start audio file recording
      await _soundRecorder.startRecorder(
        toFile: _recordedAudioPath,
        codec: Codec.pcm16WAV,
        numChannels: 1,
        sampleRate: 16000,
      );

      // 2. Start speech-to-text for instant visual caption
      if (_speechReady) {
        try {
          await _speech.listen(
            onResult: (result) {
              if (mounted && result.recognizedWords.isNotEmpty) {
                // Show live speech directly
                final current = _storyCtrl.text.trim();
                final words = result.recognizedWords;
                if (current.isEmpty) {
                  _storyCtrl.text = words;
                }
              }
            },
            listenOptions: stt.SpeechListenOptions(
              listenMode: stt.ListenMode.dictation,
              partialResults: true,
            ),
          );
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Start recording error: $e');
      setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    setState(() {
      _isRecording = false;
      _isTranscribing = true;
    });

    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}

    String? audioPath;
    try {
      audioPath = await _soundRecorder.stopRecorder();
    } catch (e) {
      debugPrint('Stop recorder error: $e');
    }

    final pathToUse = audioPath ?? _recordedAudioPath;

    // Transcribe via Groq Whisper AI
    if (pathToUse != null) {
      final text = await _profileService.transcribeAudio(pathToUse, language: 'hi');
      if (mounted && text != null && text.trim().isNotEmpty) {
        final existing = _storyCtrl.text.trim();
        setState(() {
          _storyCtrl.text = existing.isNotEmpty ? '$existing\n\n$text' : text;
        });
      }
    }

    if (mounted) {
      setState(() => _isTranscribing = false);
    }
  }

  // ─── AI STORY POLISH ────────────────────────────────────────────────────────

  Future<void> _enhanceStoryWithAI() async {
    final raw = _storyCtrl.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record or type some story details first!'),
          backgroundColor: AppColors.terracotta,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isPolishingStory = true);
    final enhanced = await _profileService.enhanceStoryWithAI(
      rawStory: raw,
      artisanName: _profile?.name ?? 'Artisan',
      craft: _profile?.craftSpecialization ?? 'Handmade Art',
    );

    if (mounted) {
      setState(() => _isPolishingStory = false);
      if (enhanced != null && enhanced.isNotEmpty) {
        setState(() {
          _storyCtrl.text = enhanced;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story polished with AI! Review and save to database.'),
            backgroundColor: AppColors.oliveGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ─── SAVE STORY TO DB ──────────────────────────────────────────────────────

  Future<void> _saveStory() async {
    final story = _storyCtrl.text.trim();
    setState(() => _isSavingStory = true);

    final success = await _profileService.saveStory(story);

    if (mounted) {
      setState(() {
        _isSavingStory = false;
        if (_profile != null) {
          _profile = _profile!.copyWith(craftStory: story);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Story saved directly to database!' : 'Failed to save story.'),
          backgroundColor: success ? AppColors.oliveGreen : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
      );
    }

    final profile = _profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          'Artisan Profile',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.cream,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Edit Profile Details',
            icon: const Icon(Icons.edit_rounded, size: 20),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (result == true || mounted) {
                _loadProfile();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.terracotta,
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
          children: [
            // 1. Top Photo & Hero Identity (NO Followers, NO Products counters)
            _buildArtisanHero(profile),

            const SizedBox(height: 20),

            // 2. "My Story" with Mic & Live Groq Transcription
            _buildStorySection(profile),

            const SizedBox(height: 20),

            // 3. Craft Info & Bio
            _buildCraftInfoCard(profile),

            const SizedBox(height: 20),

            // 4. Action Buttons (Edit Profile & Sign Out)
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ─── 1. ARTISAN HERO (PHOTO + IDENTITY ONLY) ───────────────────────────────

  Widget _buildArtisanHero(ArtisanProfile? profile) {
    final name = profile?.name.isNotEmpty == true ? profile!.name : 'Artisan';
    final craft = profile?.craftSpecialization.isNotEmpty == true ? profile!.craftSpecialization : 'Traditional Crafts';
    final location = profile?.location.isNotEmpty == true
        ? (profile!.state.isNotEmpty ? '${profile.location}, ${profile.state}' : profile.location)
        : '';
    final avatarUrl = profile?.avatarUrl ?? '';
    final hasPhoto = avatarUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          // Profile photo with Camera Badge Icon
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.terracotta, AppColors.mustardGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.terracotta.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFFFDF8F0),
                    backgroundImage: hasPhoto
                        ? (avatarUrl.startsWith('http')
                            ? NetworkImage(avatarUrl)
                            : FileImage(File(avatarUrl)) as ImageProvider)
                        : null,
                    child: _isUploadingPhoto
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(color: AppColors.terracotta, strokeWidth: 2.5),
                          )
                        : (!hasPhoto
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'A',
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.terracotta,
                                ),
                              )
                            : null),
                  ),
                ),

                // Tap icon to add / change profile photo
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.terracotta,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 17, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Artisan Name with Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified_rounded, size: 20, color: AppColors.oliveGreen),
            ],
          ),

          const SizedBox(height: 6),

          // Craft Specialization Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              craft,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.terracotta,
              ),
            ),
          ),

          if (location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_rounded, size: 15, color: AppColors.brown.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brown.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],

          if ((profile?.yearsOfExperience ?? 0) > 0) ...[
            const SizedBox(height: 6),
            Text(
              '${profile!.yearsOfExperience}+ years of master craftsmanship',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.brown.withValues(alpha: 0.55),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 2. "MY STORY" WITH MIC OPTION & GROQ AI ───────────────────────────────

  Widget _buildStorySection(ArtisanProfile? profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_stories_rounded, color: AppColors.terracotta, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'My Craft Story',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),
              ),
              if (_storyCtrl.text.trim().isNotEmpty)
                TextButton.icon(
                  onPressed: _isPolishingStory ? null : _enhanceStoryWithAI,
                  icon: _isPolishingStory
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mustardGold),
                        )
                      : const Icon(Icons.auto_awesome, size: 14, color: AppColors.mustardGold),
                  label: Text(
                    _isPolishingStory ? 'Polishing...' : 'AI Polish',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mustardGold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            'Tell buyers how you learned your craft, the tradition in your family, and what makes your work special.',
            style: TextStyle(fontSize: 12.5, color: AppColors.brown.withValues(alpha: 0.65), height: 1.4),
          ),

          const SizedBox(height: 16),

          // ─── MIC / VOICE RECORDING CARD ───
          GestureDetector(
            onTap: _isTranscribing
                ? null
                : (_isRecording ? _stopRecording : _startRecording),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isRecording
                      ? [Colors.red.shade50, Colors.red.shade100.withValues(alpha: 0.6)]
                      : [
                          AppColors.terracotta.withValues(alpha: 0.07),
                          AppColors.mustardGold.withValues(alpha: 0.12),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isRecording
                      ? Colors.red.shade400
                      : AppColors.terracotta.withValues(alpha: 0.25),
                  width: _isRecording ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : AppColors.terracotta,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : AppColors.terracotta).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isTranscribing
                              ? 'Transcribing your voice with Groq AI...'
                              : _isRecording
                                  ? 'Recording (${_recordingSeconds}s) • Tap to Stop'
                                  : 'Speak Your Story (बोलकर बताएं)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _isRecording ? Colors.red.shade700 : AppColors.brown,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isTranscribing
                              ? 'Converting speech to text...'
                              : _isRecording
                                  ? 'Listening to your voice in Hindi, English...'
                                  : 'Tap mic & speak in any language to auto-fill story',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.brown.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isTranscribing) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: AppColors.terracotta, strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Story Text Area (Editable directly)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.brown.withValues(alpha: 0.15)),
            ),
            child: TextField(
              controller: _storyCtrl,
              maxLines: 7,
              minLines: 4,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppColors.charcoal,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: 'Your craft story will appear here after speaking, or you can type directly...\n\n(e.g. "I learned pottery from my grandfather in Khurja. For 20 years I have molded natural clay on traditional foot-wheels...")',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.brown.withValues(alpha: 0.35),
                  height: 1.5,
                ),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Save Story Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSavingStory ? null : _saveStory,
              icon: _isSavingStory
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text(
                _isSavingStory ? 'Saving...' : 'Save Story~',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. CRAFT INFO & BIO ───────────────────────────────────────────────────

  Widget _buildCraftInfoCard(ArtisanProfile? profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.brush_rounded, color: AppColors.terracotta, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'About My Craft',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.palette_outlined, 'Craft Type', profile?.craftSpecialization.isNotEmpty == true ? profile!.craftSpecialization : 'Traditional Artisan Handcraft'),
          const Divider(height: 20, thickness: 0.7, color: Color(0xFFEEEEEE)),
          _buildInfoRow(Icons.location_on_outlined, 'Origin / Region', profile?.location.isNotEmpty == true ? (profile!.state.isNotEmpty ? '${profile.location}, ${profile.state}' : profile.location) : 'India'),
          const Divider(height: 20, thickness: 0.7, color: Color(0xFFEEEEEE)),
          _buildInfoRow(Icons.timer_outlined, 'Experience', '${profile?.yearsOfExperience ?? 0} Years'),
          if (profile?.bio.isNotEmpty == true) ...[
            const Divider(height: 20, thickness: 0.7, color: Color(0xFFEEEEEE)),
            _buildInfoRow(Icons.info_outline_rounded, 'Bio', profile!.bio),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.terracotta),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brown.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ],
    );
  }

  // ─── 4. ACTION BUTTONS ─────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (result == true || mounted) {
                _loadProfile();
              }
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Full Profile Details', style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.terracotta,
              side: const BorderSide(color: AppColors.terracotta, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
            label: const Text('Sign Out of Account', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out from your artisan account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      }
    }
  }
}
