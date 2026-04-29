# Multi-Language Support Implementation Guide

## Overview
Your Flutter app now supports multiple Indian languages: **English, Telugu, Hindi, Tamil, and Kannada**. Users can select one or more languages and view content in their preferred languages simultaneously.

## Files Created

### Core Files
1. **`language_provider.dart`** - Manages selected languages using Provider pattern and SharedPreferences
2. **`translation_service.dart`** - Loads and manages translation data from JSON files
3. **`language_selection_screen.dart`** - UI for users to select languages
4. **`multi_language_widgets.dart`** - Reusable widgets for displaying multi-language content
5. **`example_multi_language.dart`** - Example implementation showing how to use the system

### Translation Files (in `assets/translations/`)
- `en.json` - English translations
- `te.json` - Telugu translations
- `hi.json` - Hindi translations
- `ta.json` - Tamil translations
- `kn.json` - Kannada translations

## How to Use

### 1. **Select Languages**
Click the language icon (🌐) in the top navigation bar to open the language selection screen. Users can select multiple languages as checkboxes.

### 2. **Display Content in Multiple Languages**

#### Option A: Using MultiLanguageContent Widget
```dart
import 'package:poston_app/multi_language_widgets.dart';

// In your widget
MultiLanguageContent(key: 'welcome')
```

#### Option B: Manual Translation
```dart
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'translation_service.dart';

Consumer<LanguageProvider>(
  builder: (context, languageProvider, _) {
    final translationService = TranslationService();
    return Column(
      children: [
        ...languageProvider.selectedLanguages.map((language) {
          final text = translationService.translate('welcome', language);
          return Text('$language: $text');
        }).toList(),
      ],
    );
  },
)
```

#### Option C: With Custom Data
```dart
MultiLanguageContent(
  key: 'temple_name',
  customTranslations: {
    'English': 'Varanasi Temple',
    'Telugu': 'వారణసి ఆలయం',
    'Hindi': 'वाराणसी मंदिर',
    'Tamil': 'வாரணசி கோயில்',
    'Kannada': 'ವಾರಣಸಿ ದೇವಾಲಯ',
  },
)
```

## Adding New Translations

### Step 1: Add to JSON Files
Edit each translation file (en.json, te.json, hi.json, ta.json, kn.json):

```json
{
  "existing_key": "existing_value",
  "new_key": "new translation",
  ...
}
```

### Step 2: Use in Your Code
```dart
final translation = translationService.translate('new_key', 'Telugu');
```

## Integrating with Your Existing Screens

### Example: Update Profile Screen
```dart
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'translation_service.dart';

// In your build method
Consumer<LanguageProvider>(
  builder: (context, languageProvider, _) {
    final translationService = TranslationService();
    
    return Column(
      children: [
        ...languageProvider.selectedLanguages.map((language) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                translationService.translate('profile', language),
              ),
            ),
          );
        }).toList(),
      ],
    );
  },
)
```

## How Language Selection Works

1. **Persistence**: Selected languages are saved to device storage using SharedPreferences
2. **Default**: If no languages are selected, English is used by default
3. **Validation**: Users must always have at least one language selected
4. **Real-time Updates**: All widgets update automatically when languages are changed (thanks to Provider)

## Accessing Selected Languages

```dart
// Get selected languages
final selectedLanguages = context.read<LanguageProvider>().selectedLanguages;

// Check if a language is selected
final isTeluguSelected = context.read<LanguageProvider>().isLanguageSelected('Telugu');

// Modify selected languages programmatically
context.read<LanguageProvider>().setLanguages(['English', 'Telugu', 'Hindi']);
```

## Translation Service Methods

```dart
final translationService = TranslationService();

// Translate a single key for a specific language
String text = translationService.translate('welcome', 'Telugu');

// Get translations for a key in multiple languages (as list)
List<String> translations = translationService.getTranslations('welcome', ['English', 'Telugu', 'Hindi']);

// Get translations as a map
Map<String, String> translationsMap = translationService.getTranslationsMap('welcome', ['English', 'Telugu']);
```

## Best Practices

1. **Use Translation Keys**: Always use consistent keys for translations
2. **Store Common Keys**: Put frequently used translations in the translation files
3. **Context-Specific**: For user data from Supabase, use custom translations
4. **Testing**: Test with all languages to ensure proper display
5. **Text Length**: Consider that translated text may be longer/shorter than English

## Example: Displaying Supabase Data in Multiple Languages

```dart
// Fetch from Supabase
final response = await Supabase.instance.client
    .from('temples')
    .select('name_en, name_te, name_hi, name_ta, name_kn')
    .eq('id', templeId)
    .single();

// Display in selected languages
Consumer<LanguageProvider>(
  builder: (context, languageProvider, _) {
    return Column(
      children: [
        if (languageProvider.isLanguageSelected('English'))
          Text(response['name_en']),
        if (languageProvider.isLanguageSelected('Telugu'))
          Text(response['name_te']),
        if (languageProvider.isLanguageSelected('Hindi'))
          Text(response['name_hi']),
        if (languageProvider.isLanguageSelected('Tamil'))
          Text(response['name_ta']),
        if (languageProvider.isLanguageSelected('Kannada'))
          Text(response['name_kn']),
      ],
    );
  },
)
```

## Troubleshooting

### Translations Not Loading
- Ensure `TranslationService().init()` is called in `main()`
- Check that translation files exist in `assets/translations/`
- Verify `pubspec.yaml` includes the assets path

### Language Not Persisting
- Check that `shared_preferences` package is installed
- Ensure `LanguageProvider` is wrapped around your app

### Widgets Not Updating
- Make sure you're using `Consumer<LanguageProvider>` or `context.watch<LanguageProvider>()`
- Verify `LanguageProvider` is in the widget tree

## Next Steps

1. Run `flutter pub get` to install dependencies
2. Update your Supabase database schema to store names in multiple languages
3. Review `example_multi_language.dart` for implementation patterns
4. Update your app screens using the guides above
5. Test with different language combinations
