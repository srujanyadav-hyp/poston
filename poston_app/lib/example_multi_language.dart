import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'translation_service.dart';
import 'multi_language_widgets.dart';

/// Example screen showing how to implement multi-language support
class ExampleMultiLanguageScreen extends StatelessWidget {
  const ExampleMultiLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translationService = TranslationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Language Example'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return Column(
              children: [
                // Show selected languages
                const LanguageSelector(),

                // Example 1: Display simple translated key
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Example 1: Simple Translation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MultiLanguageContent(translationKey: 'welcome'),
                    ],
                  ),
                ),

                const Divider(thickness: 2, height: 32),

                // Example 2: Display with custom translations
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Example 2: Custom Content',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MultiLanguageContent(
                        translationKey: 'custom_key',
                        customTranslations: {
                          'English': 'This is a temple in India',
                          'Telugu': 'ఇది భారతదేశంలో ఒక ఆలయం',
                          'Hindi': 'यह भारत में एक मंदिर है',
                          'Tamil': 'இது இந்தியாவில் ஒரு கோயில்',
                          'Kannada': 'ಇದು ಭಾರತದಲ್ಲಿ ಒಂದು ದೇವಾಲಯ',
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(thickness: 2, height: 32),

                // Example 3: Display all translations for a key
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Example 3: All Available Languages',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...languageProvider.availableLanguages.map((language) {
                        String translation =
                            translationService.translate('login', language);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.withValues(
                                  alpha: 0.2,
                                ),
                                child: Text(
                                  language[0],
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(language),
                              subtitle: Text(translation),
                              trailing: languageProvider.isLanguageSelected(
                                language,
                              )
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Example of how to use translations in your widgets
class TemplateExample extends StatelessWidget {
  const TemplateExample({super.key});

  @override
  Widget build(BuildContext context) {
    final translationService = TranslationService();

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return ListView(
          children: [
            ...languageProvider.selectedLanguages.map((language) {
              final title = translationService.translate('welcome', language);
              final subtitle =
                  translationService.translate('language_settings', language);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(subtitle),
                  leading: Icon(
                    Icons.language,
                    color: Colors.orange,
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
