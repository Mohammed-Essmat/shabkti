import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shabakti/core/app_strings.dart';

class LanguageProvider extends ChangeNotifier {
  late bool _isArabic;
  late AppStrings _strings;

  bool get isArabic => _isArabic;
  AppStrings get strings => _strings;
  TextDirection get textDirection => _isArabic ? TextDirection.rtl : TextDirection.ltr;
  Locale get locale => Locale(_isArabic ? 'ar' : 'en');

  LanguageProvider() {
    final systemLang = ui.PlatformDispatcher.instance.locale.languageCode;
    _isArabic = systemLang == 'ar';
    _strings = AppStrings(_isArabic);
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_language');
    if (saved != null) {
      _isArabic = saved == 'ar';
      _strings = AppStrings(_isArabic);
      notifyListeners();
    }
  }

  Future<void> toggleLanguage() async {
    _isArabic = !_isArabic;
    _strings = AppStrings(_isArabic);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _isArabic ? 'ar' : 'en');
  }

  String get languageLabel => _isArabic ? 'English' : 'العربية';
  IconData get languageIcon => Icons.language;
}
