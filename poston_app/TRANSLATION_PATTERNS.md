// BEFORE: Hardcoded strings
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Screen'),  // ❌ Hardcoded
      ),
      body: Column(
        children: [
          Text('Welcome!'),  // ❌ Hardcoded
          Text('Email: ${user.email}'),  // ❌ Mixed hardcoded and data
          ElevatedButton(
            child: Text('Sign Out'),  // ❌ Hardcoded
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// AFTER: Using translations
import 'translation_helper.dart';
import 'package:provider/provider.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatedText('home'),  // ✅ Translated
      ),
      body: Column(
        children: [
          TranslatedText('welcome'),  // ✅ Translated
          
          // For mixed content (data + translation)
          Consumer<LanguageProvider>(
            builder: (context, provider, _) {
              final lang = provider.selectedLanguages.first;
              final emailLabel = TranslationService().translate('email', lang);
              return Text('$emailLabel: ${user.email}');  // ✅ Translated label
            },
          ),
          
          ElevatedButton(
            child: TranslatedText('sign_out_button'),  // ✅ Translated
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════

// PATTERN 1: Simple Static Text Translation
// Use this for: All UI labels, titles, button text

Before:  Text('My Profile')
After:   TranslatedText('my_profile')

Before:  Text('Sign In', style: TextStyle(fontSize: 28))
After:   TranslatedText('sign_in', style: TextStyle(fontSize: 28))

Before:  Text('No Email')
After:   TranslatedText('no_email')

// ═══════════════════════════════════════════════════════════════════

// PATTERN 2: Dynamic Text (data + translation)
// Use this for: Labels with user data

Before:
Text('Email: ${user.email}')

After:
Consumer<LanguageProvider>(
  builder: (context, provider, _) {
    final emailLabel = T.translate(context, 'email');
    return Text('$emailLabel: ${user.email}');
  },
)

// ═══════════════════════════════════════════════════════════════════

// PATTERN 3: Display All Selected Languages
// Use this for: Showing same content in multiple languages

Before:
Text('Temple Location')

After:
MultiLanguageContent(
  translationKey: 'temple_information',
  customTranslations: {
    'English': 'Varanasi Temple',
    'Telugu': 'వారణసి ఆలయం',
    'Hindi': 'वाराणसी मंदिर',
    'Tamil': 'வாரணசி கோயில்',
    'Kannada': 'ವಾರಣಸಿ ದೇವಾಲಯ',
  },
)

// ═══════════════════════════════════════════════════════════════════

// PATTERN 4: Form Fields and Input Labels
// Use this for: TextFormField, TextField

Before:
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)

After:
Consumer<LanguageProvider>(
  builder: (context, provider, _) {
    final lang = provider.selectedLanguages.first;
    return TextFormField(
      decoration: InputDecoration(
        labelText: T.translate(context, 'email'),
        hintText: TranslationService().translate('email', lang),
      ),
    );
  },
)

// ═══════════════════════════════════════════════════════════════════

// PATTERN 5: Button Text
// Use this for: All buttons

Before:
ElevatedButton(
  child: Text('Sign In'),
  onPressed: () {},
)

After:
ElevatedButton(
  child: TranslatedText('sign_in_button'),
  onPressed: () {},
)

// ═══════════════════════════════════════════════════════════════════

// PATTERN 6: SnackBar and Dialog Messages
// Use this for: Error and success messages

Before:
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Account created!')),
)

After:
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: TranslatedText('account_created')),
)

// ═══════════════════════════════════════════════════════════════════

// PATTERN 7: AppBar and Titles
// Use this for: Screen titles, headers

Before:
AppBar(
  title: Text('My Profile'),
)

After:
AppBar(
  title: TranslatedText('my_profile'),
)

// ═══════════════════════════════════════════════════════════════════

// STEP BY STEP: Convert Any Screen

// Step 1: Add imports at top
import 'translation_helper.dart';
import 'package:provider/provider.dart';

// Step 2: Find all hardcoded Text() widgets
// Example: Text('Sign In')

// Step 3: Check if text is simple or dynamic
// Simple: No variables or conditions -> Use TranslatedText
// Dynamic: Has variables or conditions -> Use Consumer<LanguageProvider>

// Step 4: Replace with pattern
// Simple:   TranslatedText('sign_in')
// Dynamic:  Use Pattern 2 example above

// Step 5: Add translation key to all 5 JSON files if not exists
// Files: assets/translations/en.json, te.json, hi.json, ta.json, kn.json

// Step 6: Test in app - change language and verify text updates

// ═══════════════════════════════════════════════════════════════════

// COMMON MISTAKES TO AVOID

❌ WRONG: const Text('Hello')  // Can't be translated
✅ RIGHT: TranslatedText('hello')

❌ WRONG: 'Welcome: ${userName}'  // Hardcoded label
✅ RIGHT: '${T.translate(context, 'welcome')}: ${userName}'

❌ WRONG: Text(myVariable)  // Using variable, not translation
✅ RIGHT: Text(T.translate(context, myKey))

❌ WRONG: Hardcoded string without adding to JSON files
✅ RIGHT: Add key to all 5 translation files first

❌ WRONG: Using TranslatedText() without importing
✅ RIGHT: import 'translation_helper.dart';

// ═══════════════════════════════════════════════════════════════════
