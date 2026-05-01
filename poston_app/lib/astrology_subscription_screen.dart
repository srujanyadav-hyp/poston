import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'upi_payment_service.dart';
import 'login_screen.dart';
import 'language_provider.dart';
import 'translation_service.dart';

class AstrologySubscriptionScreen extends StatefulWidget {
  const AstrologySubscriptionScreen({super.key});

  @override
  State<AstrologySubscriptionScreen> createState() => _AstrologySubscriptionScreenState();
}

class _AstrologySubscriptionScreenState extends State<AstrologySubscriptionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isSun = true;
  bool _isProcessing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // Very slow majestic rotation
    )..repeat(); // Continuous rotation

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 0.95), weight: 50),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.linear));

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) setState(() { _isSun = !_isSun; });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final selectedLanguages = languageProvider.selectedLanguages;
    final translationService = TranslationService();
    final lang = selectedLanguages.isEmpty ? 'English' : selectedLanguages.first;

    String t(String key) {
      return translationService.translate(key, lang);
    }

    // Check if user is already premium
    bool isPremium = false;
    final user = Supabase.instance.client.auth.currentUser;
    
    return FutureBuilder<PostgrestMap?>(
      future: (user == null || user.email == null)
        ? Future.value(null) 
        : Supabase.instance.client
            .from('user_roles')
            .select()
            .eq('email', user.email!)
            .maybeSingle()
            .catchError((_) => null),
      builder: (context, snapshot) {
        String userRole = 'user';
        if (snapshot.hasData && snapshot.data != null) {
          userRole = snapshot.data!['role'] ?? 'user';
          // Admins are always treated as premium
          if (userRole == 'admin') {
            isPremium = true;
          } else {
            isPremium = snapshot.data!['is_premium'] == true;
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFFF9F2),
          appBar: AppBar(
            backgroundColor: Colors.orange.shade800,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              t('live_astrology'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white54),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9F2),
              image: DecorationImage(
                image: AssetImage('assets/images/OM-Symbol.png'),
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(Color(0x33FFB74D), BlendMode.dstATop),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Central Zodiac/Astrology Icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade300, Colors.orange.shade800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1500),
                        switchInCurve: Curves.easeInOutBack,
                        switchOutCurve: Curves.easeInOutBack,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: RotationTransition(
                              // Spins exactly 1/2 turn into upright position
                              turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: _isSun
                            ? const Icon(Icons.wb_sunny, key: ValueKey('sun'), size: 80, color: Colors.white)
                            : Transform.flip(
                                flipX: true,
                                key: const ValueKey('moon'),
                                child: const Icon(Icons.brightness_3, size: 80, color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    t('unlock_cosmic_destiny'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    t('daily_astrology_insights'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Features List
                  _buildFeatureRow(Icons.notifications_active, t('daily_horoscope_notifications')),
                  const SizedBox(height: 16),
                  _buildFeatureRow(Icons.star, t('auspicious_timings')),
                  const SizedBox(height: 16),
                  _buildFeatureRow(Icons.shield_moon, t('planetary_transit_alerts')),
                  
                  const SizedBox(height: 50),

                  // Subscription Button
                  GestureDetector(
                    onTap: (isPremium || _isProcessing) ? null : () async {
                      final currentUser = Supabase.instance.client.auth.currentUser;
                      
                      // 1. If not logged in, go to Login Screen
                      if (currentUser == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                        return;
                      }

                      // 2. If Admin, no need to subscribe
                      if (userRole == 'admin') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Admins already have full access!'), backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      setState(() => _isProcessing = true);
                      
                      const bool success = true; // Temporary bypass

                      if (success) {
                        try {
                          await Supabase.instance.client
                              .from('user_roles')
                              .upsert({
                                'email': currentUser.email, 
                                'role': 'user', // Ensure they stay as user
                                'is_premium': true,
                              });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Successfully Subscribed!'), backgroundColor: Colors.green),
                            );
                            setState(() {}); // Refresh to show Subscribed state
                          }
                        } catch (e) {
                          if (mounted) {
                            String errorMsg = e.toString();
                            if (errorMsg.contains('PGRST204') || errorMsg.contains('PGRST205')) {
                              errorMsg = 'Please ensure you added the "is_premium" column to your user_roles table in Supabase.';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMsg), 
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      }
                      
                      if (mounted) setState(() => _isProcessing = false);
                    },
                    child: _isProcessing 
                      ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                      : ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: double.infinity,
                        height: 65,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPremium 
                              ? [Colors.green.shade400, Colors.green.shade800]
                              : [Colors.orange.shade400, Colors.orange.shade800],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: (isPremium ? Colors.green : Colors.orange).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isPremium ? 'SUBSCRIBED' : t('subscribe_now'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(isPremium ? Icons.check_circle : Icons.arrow_forward_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.orange.shade800),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.brown.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
