# Complete Multi-Language Implementation Guide

## How to Implement Translations in Your App

### 1. **Simple Text Translation** 
Use `TranslatedText` widget for any hardcoded text:

```dart
import 'translation_helper.dart';

// Instead of:
Text('My Profile')

// Use:
TranslatedText('my_profile')

// With custom styling:
TranslatedText(
  'my_profile',
  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
)
```

### 2. **Multiple Languages Display**
Show content in all selected languages:

```dart
import 'multi_language_widgets.dart';

// Display all selected languages side by side
MultiLanguageContent(translationKey: 'welcome')

// With custom translations:
MultiLanguageContent(
  translationKey: 'temple_name',
  customTranslations: {
    'English': 'Varanasi Temple',
    'Telugu': 'వారణసి ఆలయం',
    'Hindi': 'वाराणसी मंदिर',
    'Tamil': 'வாரணசி கோயில்',
    'Kannada': 'ವಾರಣಸಿ ದೇವಾಲಯ',
  },
)
```

### 3. **Get Translation in Code**
When you need the translation value in Dart code:

```dart
import 'package:provider/provider.dart';
import 'translation_helper.dart';

// Get primary language text
String text = T.translate(context, 'welcome');

// Get all language translations
List<String> allTexts = T.getAll(context, 'welcome');

// Get as map
Map<String, String> textMap = T.getAllMap(context, 'welcome');
```

### 4. **Add New Translation Keys**

**Step 1:** Edit all 5 translation files in `assets/translations/`:
- `en.json` (English)
- `te.json` (Telugu)  
- `hi.json` (Hindi)
- `ta.json` (Tamil)
- `kn.json` (Kannada)

**Step 2:** Add your key with translations:
```json
{
  "existing_key": "value",
  "your_new_key": "Your English Translation"
}
```

**Step 3:** Use in widgets:
```dart
TranslatedText('your_new_key')
```

## Complete Screen Examples

### Profile Screen
```dart
import 'translation_helper.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Use TranslatedText for all UI strings
        TranslatedText(
          'my_profile',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        
        // For dynamic content
        Consumer<LanguageProvider>(
          builder: (context, provider, _) {
            return Text(
              user.email ?? T.translate(context, 'no_email'),
            );
          },
        ),
        
        TranslatedText('sign_out_button'),
      ],
    );
  }
}
```

### Login Screen
```dart
import 'translation_helper.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TranslatedText('sign_in', style: TextStyle(fontSize: 32)),
        TextFormField(
          decoration: InputDecoration(
            labelText: T.translate(context, 'email'),
          ),
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: T.translate(context, 'password'),
          ),
        ),
        ElevatedButton(
          child: TranslatedText('sign_in_button'),
          onPressed: () {},
        ),
      ],
    );
  }
}
```

### Home Screen
```dart
import 'translation_helper.dart';
import 'multi_language_widgets.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TranslatedText('home', style: TextStyle(fontSize: 24)),
        
        // Display data in multiple languages
        MultiLanguageContent(
          translationKey: 'temple_information',
          customTranslations: {
            'English': 'Temple Location: Varanasi',
            'Telugu': 'ఆలయ ప్రదేశం: వారణసి',
            'Hindi': 'मंदिर स्थान: वाराणसी',
            'Tamil': 'கோயில் இடம்: வாரணசி',
            'Kannada': 'ದೇವಾಲಯ ಸ್ಥಾನ: ವಾರಣಸಿ',
          },
        ),
      ],
    );
  }
}
```

## All Available Translation Keys

### Basic UI
- `welcome` - Welcome
- `home` - Home
- `profile` - Profile
- `chat` / `chatbot` - Chat/Chatbot
- `admin` - Admin
- `settings` - Settings
- `done` - Done
- `cancel` - Cancel
- `submit` - Submit

### Authentication
- `login` - Login
- `sign_in` - Sign In
- `sign_up` - Sign Up
- `sign_in_button` - Sign In Button text
- `sign_up_button` - Sign Up Button text
- `sign_out_button` - Sign Out Button text
- `email` - Email
- `password` - Password
- `welcome_back` - Welcome back!
- `account_created` - Account created!

### Form Fields
- `service_title` - Service Title
- `sub_heading` - Sub Heading
- `description` - Description
- `map_link` - Map Link
- `latitude` - Latitude
- `longitude` - Longitude
- `category` - Category
- `select_category` - Select Category
- `select_image` - Select Image

### Categories
- `temple_information` - Temple Information
- `tirupati` - Tirupati
- `sabarimala` - Sabarimala
- `cabs_and_travels` - Cabs and Travels
- `hotels` - Hotels
- `parking` - Parking
- `petrol_bunks` - Petrol Bunks
- `earn_with_us` - Earn with us
- `contact_and_chat` - Contact and chat

### Admin Panel
- `admin_panel` - Admin Panel
- `upload_service` - Upload Service
- `upload_banner` - Upload Banner
- `banner_title` - Banner Title
- `banner_subtitle` - Banner Subtitle
- `discount_value` - Discount Value
- `discount_text` - Discount Text
- `button_text` - Button Text
- `button_link` - Button Link

### Errors & Messages
- `error` - Error
- `success` - Success
- `loading` - Loading...
- `no_data` - No data available
- `error_signing_out` - Error signing out
- `unexpected_error` - Unexpected error
- `no_email` - No Email

### Other
- `select_language` - Select Language
- `language_settings` - Language Settings
- `location` - Location
- `image` - Image
- `devotion_app` - Devotion App
- `my_profile` - My Profile

## Quick Reference: 3 Ways to Translate

### Way 1: Simple Widget (Recommended for most cases)
```dart
TranslatedText('welcome')
```

### Way 2: Display Multiple Languages
```dart
MultiLanguageContent(translationKey: 'welcome')
```

### Way 3: Get Text Value in Code
```dart
String text = T.translate(context, 'welcome');
```

## Important Notes

✅ **Always use Translation Keys** instead of hardcoded text  
✅ **Add all UI text to translation files**  
✅ **Update all 5 language files** (en, te, hi, ta, kn)  
✅ **Test with different languages** to ensure proper display  
✅ **Translations are auto-saved** on device after selection  

## Troubleshooting

### Translations not showing?
1. Check translation file has the key
2. Verify `TranslationService().init()` was called in `main()`
3. Make sure you're using `TranslatedText` or `T.translate()`

### App not updating when language changes?
1. Use `Consumer<LanguageProvider>` for dynamic updates
2. Use `TranslatedText` widget (handles auto-update)
3. Avoid storing translation strings - always fetch them

### Missing translations?
1. Edit all 5 JSON files (en, te, hi, ta, kn)
2. Use same key in all files
3. Ensure JSON is valid (no syntax errors)
