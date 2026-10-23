import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Backend selection logic:
///
///   API_MODE=auto  -> local backend pehle try hota hai, warna BACKEND_URL (Render)
///   API_MODE=local -> sirf LAN/local backend (BACKEND_IP:BACKEND_PORT)
///   API_MODE=prod  -> sirf deployed backend (BACKEND_URL)
class ApiConfig {
  static String? _customBaseUrl;
  static String _envIp = '127.0.0.1';
  static String _envPort = '8000';
  static String _envMode = 'auto';
  static String _envProdUrl = '';
  static String _envGroqApiKey = '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';
  static String? _resolvedBaseUrl;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final envString = await rootBundle.loadString('.env');
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
          } else if (key == 'API_MODE' && val.isNotEmpty) {
            _envMode = val;
          } else if (key == 'BACKEND_URL' && val.isNotEmpty) {
            _envProdUrl = val;
          }
        }
      }
    } catch (e) {
      debugPrint('ApiConfig: could not load .env ($e). Using default IP: $_envIp');
    }

    // --dart-define=BACKEND_IP=... (and friends) override the file values
    const defineIp = String.fromEnvironment('BACKEND_IP');
    if (defineIp.isNotEmpty) _envIp = defineIp;
    const definePort = String.fromEnvironment('BACKEND_PORT');
    if (definePort.isNotEmpty) _envPort = definePort;
    const defineGroq = String.fromEnvironment('GROQ_API_KEY');
    if (defineGroq.isNotEmpty) _envGroqApiKey = defineGroq;
    const defineMode = String.fromEnvironment('API_MODE');
    if (defineMode.isNotEmpty) _envMode = defineMode;
    const defineProdUrl = String.fromEnvironment('BACKEND_URL');
    if (defineProdUrl.isNotEmpty) _envProdUrl = defineProdUrl;

    _envMode = _envMode.trim().toLowerCase();
    if (_envMode != 'local' && _envMode != 'prod') _envMode = 'auto';
    _envProdUrl = _normalize(_envProdUrl);

    if (_envMode == 'prod' && _envProdUrl.isNotEmpty) {
      // Render free service 15 min idle pe so jaati hai — launch pe health check
      // se ek baar wake ho jaati hai, warna pehli API request slow/fail hoti.
      await _warmProduction();
      _resolvedBaseUrl = _envProdUrl;
    } else if (_envMode == 'auto') {
      await _resolveAuto();
    }

    _initialized = true;
    debugPrint('ApiConfig: mode=$_envMode base=$baseUrl (local=$_deviceLocalBaseUrl prod=${_envProdUrl.isEmpty ? "unset" : _envProdUrl})');
  }

  /// auto mode: local backend health-check karo (parallel me Render warm hota hai),
  /// jo pehle healthy mile wahi primary ban jata hai.
  static Future<void> _resolveAuto() async {
    final localUrls = _localCandidates();
    final localFuture = _firstHealthy(localUrls, const Duration(seconds: 2));
    final prodFuture = _envProdUrl.isEmpty ? null : _warmProduction();

    final localUrl = await localFuture;
    if (localUrl != null) {
      _resolvedBaseUrl = localUrl;
      if (prodFuture != null) unawaited(prodFuture); // Render warm, baad me instant fallback
      return;
    }

    if (prodFuture != null) await prodFuture;
    _resolvedBaseUrl = _envProdUrl.isNotEmpty ? _envProdUrl : (localUrls.isNotEmpty ? localUrls.first : _deviceLocalBaseUrl);
    debugPrint('ApiConfig: local backend nahi mila -> using $_resolvedBaseUrl');
  }

  /// Wakes the deployed backend (cold start can take up to ~60s on Render free tier).
  /// Never throws and always reports the final result.
  static Future<bool> _warmProduction() async {
    if (_envProdUrl.isEmpty) return false;
    final ok = await _isHealthy(_envProdUrl, const Duration(seconds: 60));
    if (!ok) {
      debugPrint('ApiConfig: $_envProdUrl health check failed/took too long — continuing anyway');
    }
    return ok;
  }

  static String _normalize(String url) {
    var u = url.trim();
    if (u.isEmpty) return '';
    if (!u.startsWith('http://') && !u.startsWith('https://')) u = 'https://$u';
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  static Future<String?> _firstHealthy(List<String> urls, Duration timeout) async {
    if (urls.isEmpty) return null;
    final results = await Future.wait(urls.map((u) async {
      return await _isHealthy(u, timeout) ? u : null;
    }));
    for (final r in results) {
      if (r != null) return r;
    }
    return null;
  }

  static Future<bool> _isHealthy(String baseUrl, Duration timeout) async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/health')).timeout(timeout);
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static String get _deviceLocalBaseUrl {
    try {
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        return 'http://127.0.0.1:$_envPort';
      }
    } catch (_) {
      // Platform not available
    }
    return 'http://$_envIp:$_envPort';
  }

  static List<String> _localCandidates() {
    final list = <String>[
      _deviceLocalBaseUrl,
      'http://$_envIp:$_envPort',
      'http://10.0.2.2:$_envPort', // Android emulator -> host PC
      'http://127.0.0.1:$_envPort',
      'http://localhost:$_envPort',
    ];
    final seen = <String>{};
    return [for (final u in list) if (seen.add(u)) u];
  }

  static void setBaseUrl(String url) {
    _customBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String get backendIp => _envIp;
  static String get backendPort => _envPort;
  static String get groqApiKey => _envGroqApiKey;
  static String get apiMode => _envMode;
  static String get productionUrl => _envProdUrl;

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    return _resolvedBaseUrl ?? _deviceLocalBaseUrl;
  }

  static List<String> get candidateUrls {
    final list = <String>[baseUrl];

    final candidates = <String>[
      if (_envProdUrl.isNotEmpty) _envProdUrl,
      ..._localCandidates(),
    ];

    for (final c in candidates) {
      if (c.isNotEmpty && !list.contains(c)) {
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
