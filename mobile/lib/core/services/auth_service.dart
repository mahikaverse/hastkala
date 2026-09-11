import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/router.dart';
import '../models/user_role.dart';
import 'api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String supabaseUrl = 'https://acutpnwhubbmptbgtnih.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_ewNadQffEciWXRi0wWYTSg_7wico077';

  static const String _keyUserRole = 'hastkala_user_role';
  static const String _keyUserName = 'hastkala_user_name';
  static const String _keyOnboardingSeen = 'hastkala_onboarding_seen';

  SharedPreferences? _prefs;

  /// Initialize Supabase Flutter and Local Preferences
  Future<void> init() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          autoRefreshToken: true,
        ),
      );
    } catch (e) {
      developer.log('Supabase already initialized or failed: $e', name: 'AuthService');
    }

    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      developer.log('SharedPreferences init error: $e', name: 'AuthService');
    }
  }

  bool get _isSupabaseReady {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  SupabaseClient? get client {
    if (!_isSupabaseReady) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser => client?.auth.currentUser;

  Session? get currentSession => client?.auth.currentSession;

  /// Whether the user has a valid active session
  bool get isLoggedIn => currentSession != null;

  /// Get user display name
  String get userName {
    final metaName = currentUser?.userMetadata?['name'] as String?;
    if (metaName != null && metaName.isNotEmpty) return metaName;
    return _prefs?.getString(_keyUserName) ?? 'Artisan';
  }

  /// Get user email
  String? get userEmail => currentUser?.email;

  /// Get user role from Supabase metadata or local cache
  UserRole get userRole {
    final rawRole = currentUser?.userMetadata?['role'] as String?;
    if (rawRole != null && rawRole.isNotEmpty) {
      final role = UserRole.fromString(rawRole);
      _prefs?.setString(_keyUserRole, role.dbValue);
      return role;
    }

    final cached = _prefs?.getString(_keyUserRole);
    if (cached != null && cached.isNotEmpty) {
      return UserRole.fromString(cached);
    }

    return UserRole.seller; // Default
  }

  /// Save role to user metadata and local cache
  Future<void> saveRole(UserRole role) async {
    await _prefs?.setString(_keyUserRole, role.dbValue);
    try {
      if (currentUser != null && client != null) {
        await client!.auth.updateUser(
          UserAttributes(data: {'role': role.dbValue}),
        );
      }
    } catch (e) {
      developer.log('Error updating user role metadata: $e', name: 'AuthService');
    }
  }

  /// Onboarding status
  bool get hasSeenOnboarding => _prefs?.getBool(_keyOnboardingSeen) ?? false;

  Future<void> setOnboardingSeen(bool seen) async {
    await _prefs?.setBool(_keyOnboardingSeen, seen);
  }

  /// Map role to destination home screen
  String getHomeRouteForRole([UserRole? role]) {
    final r = role ?? userRole;
    switch (r) {
      case UserRole.seller:
      case UserRole.b2bSeller:
        return AppRoutes.artisanDashboard;
      case UserRole.buyer:
        return AppRoutes.buyerHome;
    }
  }

  /// Real Supabase Login with email & password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (client == null) {
      return AuthResult.failure('Authentication service is currently unavailable.');
    }
    final cleanEmail = email.trim().toLowerCase();
    try {
      final res = await client!.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      if (res.user != null) {
        final roleStr = res.user?.userMetadata?['role'] as String?;
        final role = UserRole.fromString(roleStr);
        await _prefs?.setString(_keyUserRole, role.dbValue);

        final nameStr = res.user?.userMetadata?['name'] as String?;
        if (nameStr != null && nameStr.isNotEmpty) {
          await _prefs?.setString(_keyUserName, nameStr);
        }

        return AuthResult.success(user: res.user, role: role);
      }

      return AuthResult.failure('Login failed. Please check your credentials.');
    } on AuthException catch (e) {
      developer.log('AuthException on login: ${e.message}', name: 'AuthService');
      String message = e.message;
      if (e.message.contains('Invalid login credentials')) {
        message = 'Invalid email or password. Please try again.';
      } else if (e.message.contains('Email not confirmed')) {
        message = 'Email is not confirmed yet. Please verify your email.';
      }
      return AuthResult.failure(message);
    } catch (e) {
      developer.log('General error on login: $e', name: 'AuthService');
      return AuthResult.failure('Connection error. Please check your internet connection.');
    }
  }

  /// Real Supabase Sign Up / Create Account
  /// Uses backend admin endpoint to bypass email confirmation limits and auto-confirm,
  /// then immediately signs in so the user is directly logged in.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? craft,
    String? businessName,
    String? phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    // 1. Try registering via backend admin service (auto-confirmed, zero SMTP limit)
    bool backendRegistered = false;
    String? backendError;

    for (final host in ApiConfig.candidateUrls) {
      try {
        final uri = Uri.parse('$host/api/auth/register');
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': cleanName,
            'email': cleanEmail,
            'password': password,
            'role': role.dbValue,
            if (craft != null && craft.isNotEmpty) 'craft': craft,
            if (businessName != null && businessName.isNotEmpty) 'business_name': businessName,
            if (phone != null && phone.isNotEmpty) 'phone': phone,
          }),
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200 || res.statusCode == 201) {
          backendRegistered = true;
          break;
        } else {
          final data = jsonDecode(res.body);
          backendError = data['detail'] ?? data['message'] ?? 'Registration failed.';
          if (res.statusCode == 400 || res.statusCode == 422) {
            // Definite error like account already exists
            return AuthResult.failure(backendError ?? 'Registration failed.');
          }
        }
      } catch (_) {
        continue;
      }
    }

    // 2. If backend was unreachable, fallback to direct Supabase sign up
    if (!backendRegistered && client != null) {
      try {
        final res = await client!.auth.signUp(
          email: cleanEmail,
          password: password,
          data: {
            'name': cleanName,
            'role': role.dbValue,
            if (craft != null && craft.isNotEmpty) 'craft': craft,
            if (businessName != null && businessName.isNotEmpty) 'business_name': businessName,
            if (phone != null && phone.isNotEmpty) 'phone': phone,
          },
        );

        if (res.session != null) {
          await _prefs?.setString(_keyUserRole, role.dbValue);
          await _prefs?.setString(_keyUserName, cleanName);
          return AuthResult.success(user: res.user, role: role);
        }
      } on AuthException catch (e) {
        return AuthResult.failure(e.message);
      } catch (e) {
        if (backendError != null) return AuthResult.failure(backendError);
      }
    }

    // 3. Immediately sign in with the new credentials
    final loginResult = await login(email: cleanEmail, password: password);
    if (loginResult.isSuccess) {
      await _prefs?.setString(_keyUserRole, role.dbValue);
      await _prefs?.setString(_keyUserName, cleanName);
      return AuthResult.success(user: loginResult.user, role: role);
    }

    return loginResult;
  }

  /// Sign out and clear stored session
  Future<void> signOut() async {
    try {
      if (client != null) {
        await client!.auth.signOut();
      }
    } catch (e) {
      developer.log('SignOut error: $e', name: 'AuthService');
    }
    await _prefs?.remove(_keyUserRole);
    await _prefs?.remove(_keyUserName);
  }
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final UserRole? role;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.role,
    this.errorMessage,
  });

  factory AuthResult.success({User? user, UserRole? role}) {
    return AuthResult._(isSuccess: true, user: user, role: role);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}
