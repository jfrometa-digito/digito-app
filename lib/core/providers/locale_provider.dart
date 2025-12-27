import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocale extends Notifier<Locale> {
  static const _kLocaleKey = 'app_locale';

  @override
  Locale build() {
    // Attempt to load saved locale, default to Spanish
    _loadLocale();
    return const Locale('es');
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_kLocaleKey);
    if (savedCode != null) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  Future<void> toggle() async {
    final newLocale = state.languageCode == 'en'
        ? const Locale('es')
        : const Locale('en');
    await setLocale(newLocale);
  }
}

final appLocaleProvider = NotifierProvider<AppLocale, Locale>(AppLocale.new);
