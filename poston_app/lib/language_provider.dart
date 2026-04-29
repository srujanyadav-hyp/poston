import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _selectedLanguagesKey = 'selected_languages';

  final List<String> availableLanguages = [
    'English',
    'Telugu',
    'Hindi',
    'Tamil',
    'Kannada'
  ];
  late List<String> selectedLanguages = [];

  LanguageProvider() {
    _loadSelectedLanguages();
  }

  Future<void> _loadSelectedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    selectedLanguages =
        prefs.getStringList(_selectedLanguagesKey) ?? ['English'];
    notifyListeners();
  }

  Future<void> toggleLanguage(String language) async {
    // 🌍 Enforces Single Global Language Context
    // To comply with standard Application Resource Bundle (.arb) localization, 
    // the app can only have one strictly defined active language at a time.
    selectedLanguages = [language]; 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedLanguagesKey, selectedLanguages);
    notifyListeners();
  }

  Future<void> setLanguages(List<String> languages) async {
    if (languages.isEmpty) {
      selectedLanguages = ['English'];
    } else {
      selectedLanguages = languages;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedLanguagesKey, selectedLanguages);
    notifyListeners();
  }

  bool isLanguageSelected(String language) {
    return selectedLanguages.contains(language);
  }

  /// 🌍 currentLocale 
  /// Resolves the raw string selection (e.g., 'Telugu') into an official 
  /// Dart `Locale` object required by MaterialApp's `supportedLocales`.
  Locale get currentLocale {
    final lang = selectedLanguages.isNotEmpty ? selectedLanguages.first : 'English';
    switch (lang) {
      case 'Telugu': return const Locale('te');
      case 'Hindi': return const Locale('hi');
      case 'Tamil': return const Locale('ta');
      case 'Kannada': return const Locale('kn');
      case 'English':
      default:
        return const Locale('en');
    }
  }
}
