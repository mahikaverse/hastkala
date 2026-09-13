import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/artisan_profile.dart';
import 'api_config.dart';
import 'data_service.dart';

class ArtisanProfileService {
  static final ArtisanProfileService _instance = ArtisanProfileService._internal();
  factory ArtisanProfileService() => _instance;
  ArtisanProfileService._internal();

  final DataService _dataService = DataService();

  SupabaseClient? get _client {
    try {
      if (Supabase.instance.isInitialized) {
        return Supabase.instance.client;
      }
    } catch (_) {}
    return null;
  }

  String? get currentUserId {
    try {
      return _client?.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  /// Get the current artisan's profile directly from Supabase DB,
  /// with automatic fallback to DataService if offline.
  Future<ArtisanProfile?> getProfile() async {
    final client = _client;
    final userId = currentUserId;

    if (client != null && userId != null && userId.isNotEmpty) {
      try {
        final data = await client
            .from('artisans')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        if (data != null) {
          final profile = ArtisanProfile.fromMap(data);
          _syncToDataService(profile);
          return profile;
        }

        // If no row exists yet for this user, create one from user metadata
        final meta = client.auth.currentUser?.userMetadata;
        final name = (meta?['name'] as String?) ??
            (meta?['full_name'] as String?) ??
            client.auth.currentUser?.email?.split('@').first ??
            'Artisan';

        final newProfile = ArtisanProfile(
          id: '',
          userId: userId,
          name: name,
          avatarUrl: '',
          bio: 'Handmade crafts crafted with love and tradition.',
          craftSpecialization: 'Traditional Crafts',
          location: 'India',
          state: '',
          yearsOfExperience: 5,
          craftStory: '',
          createdAt: DateTime.now(),
        );

        final inserted = await client
            .from('artisans')
            .insert(newProfile.toDbMap())
            .select()
            .single();

        final created = ArtisanProfile.fromMap(inserted);
        _syncToDataService(created);
        return created;
      } catch (e) {
        developer.log('Error fetching artisan from DB: $e', name: 'ArtisanProfileService');
      }
    }

    // Fallback to DataService in-memory data
    return _dataService.artisanProfiles.isNotEmpty
        ? _dataService.artisanProfiles.first
        : null;
  }

  /// Update the artisan's profile directly in Supabase DB
  Future<ArtisanProfile?> updateProfile(ArtisanProfile profile) async {
    final client = _client;
    final userId = profile.userId.isNotEmpty ? profile.userId : (currentUserId ?? '');

    ArtisanProfile updatedProfile = profile;
    if (client != null && userId.isNotEmpty) {
      try {
        final dbData = profile.toDbMap();
        dbData['user_id'] = userId;

        dynamic result;
        if (profile.id.isNotEmpty && !profile.id.startsWith('ap_')) {
          result = await client
              .from('artisans')
              .update(dbData)
              .eq('id', profile.id)
              .select()
              .maybeSingle();
        } else {
          result = await client
              .from('artisans')
              .upsert(dbData, onConflict: 'user_id')
              .select()
              .maybeSingle();
        }

        if (result != null) {
          updatedProfile = ArtisanProfile.fromMap(result);
        }
      } catch (e) {
        developer.log('Error saving profile to DB: $e', name: 'ArtisanProfileService');
      }
    }

    _syncToDataService(updatedProfile);
    return updatedProfile;
  }

  /// Save just the artisan's craft story to DB
  Future<bool> saveStory(String story) async {
    final client = _client;
    final userId = currentUserId;

    if (client != null && userId != null && userId.isNotEmpty) {
      try {
        await client
            .from('artisans')
            .update({'craft_story': story})
            .eq('user_id', userId);

        final p = _dataService.getArtisanProfileByUserId(userId) ??
            (_dataService.artisanProfiles.isNotEmpty ? _dataService.artisanProfiles.first : null);
        if (p != null) {
          _syncToDataService(p.copyWith(craftStory: story));
        }
        return true;
      } catch (e) {
        developer.log('Error saving craft story: $e', name: 'ArtisanProfileService');
      }
    }

    // Fallback update in-memory
    if (_dataService.artisanProfiles.isNotEmpty) {
      final p = _dataService.artisanProfiles.first;
      _syncToDataService(p.copyWith(craftStory: story));
      return true;
    }
    return false;
  }

  /// Upload avatar image to Supabase Storage and update DB
  Future<String?> uploadAvatar(File imageFile) async {
    final client = _client;
    final userId = currentUserId ?? 'artisan_${DateTime.now().millisecondsSinceEpoch}';

    String? publicUrl;

    if (client != null) {
      try {
        final bytes = await imageFile.readAsBytes();
        final ext = imageFile.path.split('.').last.toLowerCase();
        final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

        await client.storage.from('avatars').uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$ext',
                upsert: true,
              ),
            );

        publicUrl = client.storage.from('avatars').getPublicUrl(fileName);
      } catch (e) {
        developer.log('Supabase storage upload failed: $e. Falling back to local file.', name: 'ArtisanProfileService');
      }
    }

    // If storage is unavailable, use local file path or data URI
    final effectiveUrl = publicUrl ?? imageFile.path;

    // Save avatar URL in DB
    if (client != null && currentUserId != null && currentUserId!.isNotEmpty) {
      try {
        await client
            .from('artisans')
            .update({'avatar_url': effectiveUrl})
            .eq('user_id', currentUserId!);
      } catch (e) {
        developer.log('Error updating avatar_url in DB: $e', name: 'ArtisanProfileService');
      }
    }

    final p = _dataService.getArtisanProfileByUserId(userId) ??
        (_dataService.artisanProfiles.isNotEmpty ? _dataService.artisanProfiles.first : null);
    if (p != null) {
      _syncToDataService(p.copyWith(avatarUrl: effectiveUrl));
    }

    return effectiveUrl;
  }

  /// Transcribe audio using Groq Whisper API (whisper-large-v3-turbo)
  /// with automatic fallback to Backend `/api/ai/transcribe`.
  Future<String?> transcribeAudio(String audioPath, {String language = 'hi'}) async {
    final file = File(audioPath);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    if (bytes.length < 500) return null;

    // 1. Try Direct Groq Whisper API
    final groqKey = ApiConfig.groqApiKey;
    if (groqKey.isNotEmpty) {
      try {
        final uri = Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions');
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $groqKey'
          ..fields['model'] = 'whisper-large-v3-turbo'
          ..fields['response_format'] = 'json';

        if (language.isNotEmpty) {
          request.fields['language'] = language;
        }

        final ext = audioPath.split('.').last.toLowerCase();
        final mimeType = ext == 'mp4' || ext == 'm4a'
            ? MediaType('audio', 'mp4')
            : ext == 'wav'
                ? MediaType('audio', 'wav')
                : MediaType('audio', 'mpeg');

        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'voice_story.$ext',
          contentType: mimeType,
        ));

        final streamed = await request.send().timeout(const Duration(seconds: 25));
        if (streamed.statusCode == 200) {
          final resStr = await streamed.stream.bytesToString();
          final data = jsonDecode(resStr) as Map<String, dynamic>;
          final text = (data['text'] as String?)?.trim();
          if (text != null && text.isNotEmpty) {
            developer.log('Groq Whisper transcribed: $text', name: 'ArtisanProfileService');
            return text;
          }
        }
      } catch (e) {
        developer.log('Groq Whisper direct failed: $e', name: 'ArtisanProfileService');
      }
    }

    // 2. Fallback to Backend transcribe endpoint
    for (final host in ApiConfig.candidateUrls) {
      try {
        final uri = Uri.parse('$host/api/ai/transcribe');
        final req = http.MultipartRequest('POST', uri);
        final ext = audioPath.split('.').last.toLowerCase();
        req.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'story.$ext',
          contentType: MediaType('audio', ext == 'wav' ? 'wav' : 'mp4'),
        ));
        if (language.isNotEmpty) {
          req.fields['language'] = language;
        }

        final streamed = await req.send().timeout(const Duration(seconds: 15));
        if (streamed.statusCode == 200) {
          final body = await streamed.stream.bytesToString();
          final data = jsonDecode(body) as Map<String, dynamic>;
          final transcript = (data['transcript'] as String?)?.trim();
          if (transcript != null && transcript.isNotEmpty) {
            return transcript;
          }
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  /// Enhance spoken words into a polished, authentic artisan craft story using Groq LLM
  Future<String?> enhanceStoryWithAI({
    required String rawStory,
    required String artisanName,
    required String craft,
    String language = 'en',
  }) async {
    if (rawStory.trim().isEmpty) return null;
    final groqKey = ApiConfig.groqApiKey;
    if (groqKey.isEmpty) return null;

    try {
      final prompt = '''
You are an artisan storyteller for HastKala, a platform celebrating authentic Indian handicrafts.
An artisan named "$artisanName" who specializes in "$craft" spoke this raw personal story:

"""
$rawStory
"""

Your task:
Rewrite this into a beautiful, heartfelt, first-person craft story ("I am $artisanName...").
Guidelines:
1. Speak in the artisan's authentic voice (humble, passionate, proud of traditional roots).
2. Highlight how they learned the craft, materials used, generational heritage, and love for creating handmade pieces.
3. Keep it 2 to 3 engaging paragraphs.
4. Return ONLY the story text directly. Do NOT include markdown headers, quotes around the whole text, or conversational preambles.
''';

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $groqKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a warm, culturally sensitive craft biographer for Indian artisans.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 600,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String?;
          if (content != null && content.trim().isNotEmpty) {
            return content.trim();
          }
        }
      }
    } catch (e) {
      developer.log('AI enhance story failed: $e', name: 'ArtisanProfileService');
    }
    return null;
  }

  void _syncToDataService(ArtisanProfile profile) {
    try {
      final list = _dataService.artisanProfiles;
      final idx = list.indexWhere((p) =>
          (profile.id.isNotEmpty && p.id == profile.id) ||
          (profile.userId.isNotEmpty && p.userId == profile.userId));
      if (idx != -1) {
        _dataService.updateArtisanProfile(list[idx].id, profile);
      } else if (list.isNotEmpty) {
        _dataService.updateArtisanProfile(list.first.id, profile);
      }
    } catch (_) {}
  }
}
