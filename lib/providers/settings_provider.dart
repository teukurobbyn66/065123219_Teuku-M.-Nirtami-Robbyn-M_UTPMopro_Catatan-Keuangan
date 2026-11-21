import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kTheme = 'theme_mode';
  static const _kName = 'user_name';

  ThemeMode _themeMode = ThemeMode.system;
  String _userName = 'Pengguna';

  ThemeMode get themeMode => _themeMode;
  String get userName => _userName;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_kTheme);
    _themeMode = ThemeMode.values.firstWhere((m) => m.name == t, orElse: () => ThemeMode.system);
    _userName = prefs.getString(_kName) ?? 'Pengguna';
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners(); // tema langsung berubah
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, mode.name);
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim().isEmpty ? 'Pengguna' : name.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, _userName);
  }
}
