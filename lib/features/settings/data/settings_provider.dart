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
