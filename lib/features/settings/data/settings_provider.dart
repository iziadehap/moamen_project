import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Provider using NotifierProvider
class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadTheme();
    return false;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = !state;
    await prefs.setBool('isDarkMode', state);
  }

  bool get isDarkMode => state;
}

final themeProvider = NotifierProvider<ThemeNotifier, bool>(ThemeNotifier.new);

// Locale Provider using NotifierProvider
class LocaleNotifier extends Notifier<String> {
  @override
  String build() {
    _loadLocale();
    return 'ar';
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('locale') ?? 'ar';
  }

  Future<void> toggleLocale() async {
    final prefs = await SharedPreferences.getInstance();
    state = state == 'ar' ? 'en' : 'ar';
    await prefs.setString('locale', state);
  }

  String get currentLocale => state;
  bool get isArabic => state == 'ar';
}

final localeProvider = NotifierProvider<LocaleNotifier, String>(
  LocaleNotifier.new,
);
