import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ApiConfig {
  static String? _customBaseUrl;
  static String _envIp = '192.168.1.5';
  static String _envPort = '8000';
  static String _envGroqApiKey = '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';
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final envString = await rootBundle.loadString('assets/.env');
      for (final line in envString.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final val = parts.sublist(1).join('=').trim();
          if (key == 'BACKEND_IP' && val.isNotEmpty) {
            _envIp = val;
          } else if (key == 'BACKEND_PORT' && val.isNotEmpty) {
            _envPort = val;
          } else if (key == 'GROQ_API_KEY' && val.isNotEmpty) {
            _envGroqApiKey = val;
          }
        }
      }
    } catch (e) {
      debugPrint('ApiConfig: could not load assets/.env ($e). Using default IP: $_envIp');
    }

    // Allow --dart-define=BACKEND_IP=... override
    const defineIp = String.fromEnvironment('BACKEND_IP');
    if (defineIp.isNotEmpty) {
      _envIp = defineIp;
    }
    const definePort = String.fromEnvironment('BACKEND_PORT');
    if (definePort.isNotEmpty) {
      _envPort = definePort;
    }
    const defineGroq = String.fromEnvironment('GROQ_API_KEY');
    if (defineGroq.isNotEmpty) {
      _envGroqApiKey = defineGroq;
    }

    _initialized = true;
    debugPrint('ApiConfig initialized: http://$_envIp:$_envPort');
  }

  static void setBaseUrl(String url) {
    _customBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String get backendIp => _envIp;
  static String get backendPort => _envPort;
  static String get groqApiKey => _envGroqApiKey;

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }

    try {
      if (kIsWeb) {
        return 'http://127.0.0.1:$_envPort';
      }
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        return 'http://127.0.0.1:$_envPort';
      }
      if (Platform.isAndroid || Platform.isIOS) {
        return 'http://$_envIp:$_envPort';
      }
    } catch (_) {
      // Fallback
    }
    return 'http://$_envIp:$_envPort';
  }

  static List<String> get candidateUrls {
    final configured = baseUrl;
    final list = <String>[configured];

    final candidates = [
      'http://$_envIp:$_envPort',
      'http://10.0.2.2:$_envPort',
      'http://127.0.0.1:$_envPort',
      'http://localhost:$_envPort',
    ];

    for (final c in candidates) {
      if (!list.contains(c)) {
        list.add(c);
      }
    }
    return list;
  }

  /// Resolves relative backend image paths (e.g. /uploads/...) to full absolute URLs
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('data:image') ||
        path.startsWith('assets/')) {
      return path;
    }
    if (path.startsWith('/uploads/')) {
      return '$baseUrl$path';
    }
    if (path.startsWith('uploads/')) {
      return '$baseUrl/$path';
    }
    return path;
  }
}
