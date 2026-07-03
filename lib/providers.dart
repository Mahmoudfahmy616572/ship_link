import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null) {
      _locale = Locale(code);
    } else {
      final deviceLocale = PlatformDispatcher.instance.locale;
      _locale = deviceLocale.languageCode == 'ar'
          ? const Locale('ar')
          : const Locale('en');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  void toggleLocale() {
    setLocale(
        _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en'));
  }
}
