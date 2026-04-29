import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'translation_service.dart';

/// Helper class to easily get translations in any widget
class T {
  static String translate(BuildContext context, String key) {
    final selectedLanguages = context.read<LanguageProvider>().selectedLanguages;
    if (selectedLanguages.isEmpty) {
      return key;
    }
    // Return translation in the first selected language
    return TranslationService().translate(key, selectedLanguages.first);
  }

  static String get(BuildContext context, String key) {
    return translate(context, key);
  }

  /// Get translations for all selected languages
  static List<String> getAll(BuildContext context, String key) {
    final selectedLanguages = context.read<LanguageProvider>().selectedLanguages;
    return TranslationService().getTranslations(key, selectedLanguages);
  }

  /// Get translations as a map
  static Map<String, String> getAllMap(BuildContext context, String key) {
    final selectedLanguages = context.read<LanguageProvider>().selectedLanguages;
    return TranslationService().getTranslationsMap(key, selectedLanguages);
  }
}

/// Widget that displays translated text that updates when language changes
class TranslatedText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.translationKey, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, provider, _) {
        final selectedLanguages = provider.selectedLanguages;
        final text = selectedLanguages.isEmpty
            ? translationKey
            : TranslationService().translate(
                translationKey,
                selectedLanguages.first,
              );

        return Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// Widget that displays all selected languages side by side
class MultiLanguageText extends StatelessWidget {
  final String translationKey;
  final TextStyle? languageStyle;
  final TextStyle? contentStyle;
  final EdgeInsets padding;

  const MultiLanguageText(
    this.translationKey, {
    this.languageStyle,
    this.contentStyle,
    this.padding = const EdgeInsets.all(8.0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...provider.selectedLanguages.map((language) {
              final translation =
                  TranslationService().translate(translationKey, language);
              return Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language,
                      style: languageStyle ??
                          const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translation,
                      style: contentStyle ??
                          const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

/// Get translated text without context (use with Consumer)
String getTranslation(String key, String language) {
  return TranslationService().translate(key, language);
}
