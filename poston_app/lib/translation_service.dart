import 'dart:convert';
import 'package:flutter/services.dart';

class TranslationService {
  static final TranslationService _instance =
      TranslationService._internal();

  factory TranslationService() {
    return _instance;
  }

  TranslationService._internal();

  Map<String, Map<String, String>> _translations = {};
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final teluguData =
          await rootBundle.loadString('assets/translations/te.json');
      final hindiData =
          await rootBundle.loadString('assets/translations/hi.json');
      final tamilData =
          await rootBundle.loadString('assets/translations/ta.json');
      final kannadaData =
          await rootBundle.loadString('assets/translations/kn.json');
      final englishData =
          await rootBundle.loadString('assets/translations/en.json');

      _translations['Telugu'] =
          Map<String, String>.from(jsonDecode(teluguData));
      _translations['Hindi'] =
          Map<String, String>.from(jsonDecode(hindiData));
      _translations['Tamil'] =
          Map<String, String>.from(jsonDecode(tamilData));
      _translations['Kannada'] =
          Map<String, String>.from(jsonDecode(kannadaData));
      _translations['English'] =
          Map<String, String>.from(jsonDecode(englishData));

      _isInitialized = true;
    } catch (e) {
      print('Error loading translations: $e');
    }
  }

  String translate(String key, String language) {
    if (!_isInitialized) {
      return key;
    }
    return _translations[language]?[key] ?? key;
  }

  List<String> getTranslations(String key, List<String> languages) {
    return languages
        .map((lang) => translate(key, lang))
        .toList();
  }

  Map<String, String> getTranslationsMap(String key, List<String> languages) {
    Map<String, String> result = {};
    for (String lang in languages) {
      result[lang] = translate(key, lang);
    }
    return result;
  }
}
