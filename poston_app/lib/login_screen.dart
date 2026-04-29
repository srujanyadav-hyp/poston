import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'translation_helper.dart';
import 'language_provider.dart';
import 'translation_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoginMode = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: Curves.elasticOut.transform(value),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      size: 64,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Account Created!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "We've sent a secure confirmation link to your email. Please verify your inbox to continue.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() {
                        isLoginMode = true;
                      });
                      
                      try {
                        if (Platform.isAndroid) {
                          const AndroidIntent intent = AndroidIntent(
                            action: 'android.intent.action.MAIN',
                            category: 'android.intent.category.APP_EMAIL',
                          );
                          await intent.launch();
                        } else if (Platform.isIOS) {
                          final Uri emailLaunchUri = Uri(scheme: 'message');
                          if (await canLaunchUrl(emailLaunchUri)) {
                            await launchUrl(emailLaunchUri);
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not automatically open email app')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Open Email App",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      isLoginMode = true;
                    });
                  },
                  child: Text(
                    "I'll do it later",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> handleSubmit() async {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        if (isLoginMode) {
          await Supabase.instance.client.auth.signInWithPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
        } else {
          await Supabase.instance.client.auth.signUp(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            emailRedirectTo: 'io.supabase.poston://login-callback/',
          );
        }

        if (mounted) {
          if (isLoginMode) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: TranslatedText('welcome_back')),
            );
          } else {
            _showSuccessDialog();
          }
        }
      } on AuthException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message), backgroundColor: Colors.red),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: TranslatedText('unexpected_error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 384,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<LanguageProvider>(
                          builder: (context, provider, _) {
                            final selectedLanguages = provider.selectedLanguages;
                            final translationService = TranslationService();
                            final signInText = selectedLanguages.isEmpty
                                ? 'Sign in'
                                : translationService.translate(
                                    'sign_in',
                                    selectedLanguages.first,
                                  );
                            final signUpText = selectedLanguages.isEmpty
                                ? 'Sign up'
                                : translationService.translate(
                                    'sign_up',
                                    selectedLanguages.first,
                                  );

                            return Text(
                              isLoginMode ? signInText : signUpText,
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Consumer<LanguageProvider>(
                          builder: (context, provider, _) {
                            final selectedLanguages =
                                provider.selectedLanguages;
                            final translationService = TranslationService();
                            final lang = selectedLanguages.isEmpty
                                ? 'English'
                                : selectedLanguages.first;

                            final subtitleText =
                                translationService.translate(
                              isLoginMode
                                  ? 'sign_in'
                                  : 'sign_up',
                              lang,
                            );

                            return Text(
                              isLoginMode
                                  ? "Welcome back! Please $subtitleText to continue"
                                  : "Create a new account to continue",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        InkWell(
                          onTap: () async {
                            try {
                              setState(() => isLoading = true);
                              await Supabase.instance.client.auth
                                  .signInWithOAuth(OAuthProvider.google);
                            } on AuthException catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Unexpected error with Google sign-in',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => isLoading = false);
                            }
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 48,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.orange.shade300),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.orange,
                                  ),
                                  child: const Text(
                                    'G',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                TranslatedText(
                                  'sign_in',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.orange.shade200),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "or with email",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.orange.shade200),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Email required"
                              : null,
                          decoration: InputDecoration(
                            hintText: "Email id",
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.orange,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.orange.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Password required"
                              : null,
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.orange,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.orange.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Consumer<LanguageProvider>(
                                    builder: (context, provider, _) {
                                      final selectedLanguages = provider.selectedLanguages;
                                      final translationService = TranslationService();
                                      final lang = selectedLanguages.isEmpty ? 'English' : selectedLanguages.first;
                                      final buttonText = isLoginMode
                                          ? translationService.translate('sign_in', lang)
                                          : translationService.translate('sign_up', lang);
                                          
                                      return Text(
                                        buttonText,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isLoginMode = !isLoginMode;
                            });
                          },
                          child: Consumer<LanguageProvider>(
                            builder: (context, provider, _) {
                              final selectedLanguages = provider.selectedLanguages;
                              final translationService = TranslationService();
                              final lang = selectedLanguages.isEmpty ? 'English' : selectedLanguages.first;
                              final toggleText = isLoginMode
                                  ? translationService.translate('toggle_mode', lang)
                                  : translationService.translate('switch_to_signin', lang);
                                  
                              return Text(
                                toggleText,
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
