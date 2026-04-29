import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'translation_service.dart';

class MultiLanguageContent extends StatelessWidget {
  final String translationKey;
  final Map<String, String> customTranslations;

  const MultiLanguageContent({
    required this.translationKey,
    this.customTranslations = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final translationService = TranslationService();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...languageProvider.selectedLanguages.map((language) {
              String translation = customTranslations[language] ??
                  translationService.translate(translationKey, language);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        translation,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Languages:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ...languageProvider.selectedLanguages.map((language) {
                      return Chip(
                        label: Text(language),
                        backgroundColor: Colors.orange.withValues(alpha: 0.2),
                        labelStyle: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Change Languages',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/language_selection',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
