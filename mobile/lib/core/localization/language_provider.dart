import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_translations.dart';

class LanguageProvider extends ChangeNotifier {
  static const _prefKey = 'app_language';
  String _langCode = 'en';

  String get langCode => _langCode;

  String t(String key) => AppTranslations.t(_langCode, key);

  LanguageProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && (saved == 'en' || saved == 'hi')) {
      _langCode = saved;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String code) async {
    if (_langCode == code) return;
    _langCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }

  static LanguageProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_LanguageInherited>()!.data;
  }
}

class _LanguageInherited extends InheritedNotifier {
  final LanguageProvider data;
  const _LanguageInherited({required this.data, required super.child})
      : super(notifier: data);

  @override
  bool updateShouldNotify(_LanguageInherited old) => data != old.data;
}

class LanguageScope extends StatelessWidget {
  final LanguageProvider provider;
  final Widget child;
  const LanguageScope({super.key, required this.provider, required this.child});

  @override
  Widget build(BuildContext context) {
    return _LanguageInherited(data: provider, child: child);
  }
}
