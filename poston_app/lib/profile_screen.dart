import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'admin_screen.dart';
import 'translation_helper.dart';
import 'language_provider.dart';
import 'translation_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<bool> _checkIsAdmin(String? email) async {
    if (email == null) return false;
    try {
      final response = await Supabase.instance.client
          .from('user_roles')
          .select('role')
          .eq('email', email)
          .maybeSingle();
      return response != null && response['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TranslatedText('error_signing_out'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/temple-Minakshi-Madurai-Sundareshvara-India-goddess.webp',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = Supabase.instance.client.auth.currentSession;
          final user = session?.user;

          // Logged In View
          if (user != null) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    TranslatedText(
                      'my_profile',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Consumer<LanguageProvider>(
                        builder: (context, provider, _) {
                          final selectedLanguages = provider.selectedLanguages;
                          final translationService = TranslationService();
                          final displayText = selectedLanguages.isEmpty
                              ? (user.email ?? 'No Email')
                              : translationService.translate(
                                  'no_email',
                                  selectedLanguages.first,
                                );
                          return Text(
                            user.email ?? displayText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Admin Button - Checks role dynamically from user_roles table
                    FutureBuilder<bool>(
                      future: _checkIsAdmin(user.email),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        }

                        if (snapshot.hasData && snapshot.data == true) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.white,
                                  ),
                                  label: TranslatedText(
                                    'admin_panel',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade800,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }

                        // Not an admin, show nothing
                        return const SizedBox.shrink();
                      },
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: TranslatedText(
                          'sign_out_button',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // Login View
          return const LoginScreen();
        },
      ),
    );
  }
}
