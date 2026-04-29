# Multi-Language Quick Reference

## Installation ✅
```bash
flutter pub get
```

## Basic Setup (Already Done)
- ✅ `language_provider.dart` - Language state management
- ✅ `translation_service.dart` - Translation data loading
- ✅ `language_selection_screen.dart` - Language selector UI
- ✅ `multi_language_widgets.dart` - Reusable components
- ✅ Translation JSON files in `assets/translations/`
- ✅ Updated `main.dart` with Provider integration

## Quick Usage Examples

### 1️⃣ Show Language Selector Button
**Already added to HomeScreen!** Click the 🌐 icon in the top navbar.

### 2️⃣ Display Content in Selected Languages
```dart
import 'multi_language_widgets.dart';

MultiLanguageContent(key: 'welcome')
```

### 3️⃣ Get Translation Programmatically
```dart
import 'translation_service.dart';

final translationService = TranslationService();
String welcomeInTelugu = translationService.translate('welcome', 'Telugu');
```

### 4️⃣ Check Selected Languages
```dart
import 'package:provider/provider.dart';
import 'language_provider.dart';

final selectedLangs = context.read<LanguageProvider>().selectedLanguages;
// Returns: ['English', 'Telugu', 'Hindi']
```

### 5️⃣ Change Languages Programmatically
```dart
context.read<LanguageProvider>().setLanguages(['English', 'Telugu']);
```

## Translation File Format

Each JSON file contains key-value pairs:
```json
{
  "welcome": "Translation here",
  "login": "Login translation",
  "profile": "Profile translation"
}
```

**Files to update:**
- `assets/translations/en.json` (English)
- `assets/translations/te.json` (Telugu)
- `assets/translations/hi.json` (Hindi)
- `assets/translations/ta.json` (Tamil)
- `assets/translations/kn.json` (Kannada)

## Most Useful Components

| Component | Purpose | Location |
|-----------|---------|----------|
| `MultiLanguageContent` | Display key translation in all selected languages | `multi_language_widgets.dart` |
| `LanguageSelector` | Show selected languages with edit button | `multi_language_widgets.dart` |
| `LanguageProvider` | Manage selected languages | `language_provider.dart` |
| `TranslationService` | Get translations for any key/language | `translation_service.dart` |
| `LanguageSelectionScreen` | Full-screen language selector | `language_selection_screen.dart` |

## Real-World Example: Temple Name Display

### Scenario: Show temple name in multiple languages from Supabase

**Step 1: Store in Supabase**
```
temples table:
- id, name_en, name_te, name_hi, name_ta, name_kn
- "1", "Varanasi", "వారణసి", "वाराणसी", "வாரணசி", "ವಾರಣಸಿ"
```

**Step 2: Display in Flutter**
```dart
Consumer<LanguageProvider>(
  builder: (context, provider, _) {
    return Column(
      children: [
        if (provider.isLanguageSelected('English')) Text(temple['name_en']),
        if (provider.isLanguageSelected('Telugu')) Text(temple['name_te']),
        if (provider.isLanguageSelected('Hindi')) Text(temple['name_hi']),
        if (provider.isLanguageSelected('Tamil')) Text(temple['name_ta']),
        if (provider.isLanguageSelected('Kannada')) Text(temple['name_kn']),
      ],
    );
  },
)
```

## Common Tasks

### Add New Translation Key
1. Edit all 5 JSON files in `assets/translations/`
2. Add same key with different language values
3. Use in code: `translationService.translate('your_key', language)`

### Display Only Selected Languages
```dart
Consumer<LanguageProvider>(
  builder: (context, provider, _) {
    return Column(
      children: [
        ...provider.selectedLanguages.map((lang) {
          return Text(translationService.translate('welcome', lang));
        }).toList(),
      ],
    );
  },
)
```

### Force a Specific Language
```dart
String hindiText = translationService.translate('welcome', 'Hindi');
```

### Check if Specific Language Selected
```dart
bool isTelugu = context.read<LanguageProvider>().isLanguageSelected('Telugu');
```

## Debugging

### View all selected languages
```dart
print(context.read<LanguageProvider>().selectedLanguages);
```

### View all available languages
```dart
print(context.read<LanguageProvider>().availableLanguages);
```

### Test translation loading
```dart
print(TranslationService().translate('welcome', 'Telugu'));
```

## Important Notes

⚠️ **Must do before running:**
```bash
flutter pub get
```

✅ **Language Persistence:**
- Automatically saves to device
- Loads on app startup
- Survives app restart

✅ **Default Language:**
- English is default if nothing selected
- User can select multiple languages

✅ **Real-time Updates:**
- All UI updates automatically when languages change
- No manual refresh needed (thanks to Provider)

## File Locations

```
poston_app/
├── lib/
│   ├── main.dart (UPDATED - added Provider setup)
│   ├── language_provider.dart (NEW)
│   ├── translation_service.dart (NEW)
│   ├── language_selection_screen.dart (NEW)
│   ├── multi_language_widgets.dart (NEW)
│   ├── example_multi_language.dart (NEW - reference)
│   └── ... (other files)
├── assets/
│   └── translations/ (NEW)
│       ├── en.json
│       ├── te.json
│       ├── hi.json
│       ├── ta.json
│       └── kn.json
└── pubspec.yaml (UPDATED - added dependencies)
```

---
**See MULTILANGUAGE_GUIDE.md for detailed documentation**
