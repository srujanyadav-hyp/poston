import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'language_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.choose_language,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.language_desc,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: languageProvider.availableLanguages.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final language = languageProvider.availableLanguages[index];
                    final isSelected = languageProvider.selectedLanguages.contains(language);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          languageProvider.toggleLanguage(language);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutQuint,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.orange : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected 
                                  ? Colors.orange.withValues(alpha: 0.15) 
                                  : Colors.black.withValues(alpha: 0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.orange : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    language.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  language,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? Colors.orange.shade900 : Colors.black87,
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.orange : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.orange : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FB),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.9),
                      blurRadius: 20,
                      offset: const Offset(0, -20),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.save_preferences,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
