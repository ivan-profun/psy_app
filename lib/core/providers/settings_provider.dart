import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontSize { small, medium, large }

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  FontSize _fontSize = FontSize.medium;
  String _language = 'ru';
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  ThemeMode get themeMode => _themeMode;
  FontSize get fontSize => _fontSize;
  String get language => _language;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;

  double get textScaleFactor {
    switch (_fontSize) {
      case FontSize.small:
        return 0.9;
      case FontSize.medium:
        return 1.0;
      case FontSize.large:
        return 1.15;
    }
  }

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode');
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }

    final fontSizeString = prefs.getString('font_size');
    if (fontSizeString != null) {
      _fontSize = FontSize.values.firstWhere(
        (size) => size.toString() == fontSizeString,
        orElse: () => FontSize.medium,
      );
    }

    _language = prefs.getString('language') ?? 'ru';
    
    _pushNotifications = prefs.getBool('push_notifications') ?? true;
    _emailNotifications = prefs.getBool('email_notifications') ?? false;
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
    notifyListeners();
  }

  Future<void> setFontSize(FontSize size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font_size', size.toString());
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    if (_language == lang) return; // Не меняем, если язык тот же
    
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
    
    // Небольшая задержка для плавного перехода
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> setPushNotifications(bool value) async {
    _pushNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', value);
    notifyListeners();
  }

  Future<void> setEmailNotifications(bool value) async {
    _emailNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications', value);
    notifyListeners();
  }
}
