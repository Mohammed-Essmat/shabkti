import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isSystem => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('theme_mode') ?? 'system';
    _themeMode = switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    });
  }

  Future<void> toggleTheme() async {
    // system → dark → light → system
    final newMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
    };
    await setThemeMode(newMode);
  }

  String modeLabelFor(bool isArabic) => switch (_themeMode) {
    ThemeMode.system => isArabic ? 'تلقائي (حسب الجهاز)' : 'Auto (System)',
    ThemeMode.dark => isArabic ? 'الوضع الداكن' : 'Dark Mode',
    ThemeMode.light => isArabic ? 'الوضع الفاتح' : 'Light Mode',
  };

  IconData get modeIcon => switch (_themeMode) {
    ThemeMode.system => Icons.brightness_auto,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
  };
}
