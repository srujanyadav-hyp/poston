import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'ritual_booking_screen.dart';
import 'language_provider.dart';
import 'translation_service.dart';

class RadiantMandalaPortal extends StatefulWidget {
  final List<String> images;
  const RadiantMandalaPortal({super.key, required this.images});

  @override
  State<RadiantMandalaPortal> createState() => _RadiantMandalaPortalState();
}

class _RadiantMandalaPortalState extends State<RadiantMandalaPortal> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _currentImageIndex = 0;
  bool _isTransitioning = false;

  late AnimationController _guideController;
  late Animation<double> _guideSlideAnimation;
  late Animation<double> _guideOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _guideController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _guideSlideAnimation = Tween<double>(begin: -10.0, end: 20.0).animate(
      CurvedAnimation(parent: _guideController, curve: Curves.easeOut),
    );

    _guideOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_guideController);
    
    // Auto-advance images with ethereal timing
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {
        _isTransitioning = true;
        _currentImageIndex = (_currentImageIndex + 1) % widget.images.length;
      });
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) setState(() => _isTransitioning = false);
      });
      _startAutoAdvance();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth - 48;
        final double baseSize = math.min(availableWidth, availableHeight);
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 800),
                pageBuilder: (context, animation, secondaryAnimation) => const RitualBookingScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
                      ),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            height: availableHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. THE "GLOW-ROOM" (Depth Separation from Background Om)
                // This creates a soft focused area that separates the Mandala from the background
                Container(
                  width: baseSize * 0.95,
                  height: baseSize * 0.95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.orange.shade900.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),

                // Atmospheric Background Glow
                Container(
                  width: baseSize * 0.9,
                  height: baseSize * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.orange.withOpacity(0.3),
                        Colors.orange.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                // Outer Mandala Ring (Slow Rotation)
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: Size(baseSize * 0.85, baseSize * 0.85),
                        painter: MandalaPainter(
                          color: Colors.orange.shade800.withOpacity(0.3),
                          petals: 32,
                          radiusScale: 1.0,
                        ),
                      ),
                    );
                  },
                ),

                // Middle Mandala Ring (Reverse Rotation)
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: -_rotationController.value * 3 * math.pi,
                      child: CustomPaint(
                        size: Size(baseSize * 0.65, baseSize * 0.65),
                        painter: MandalaPainter(
                          color: Colors.orange.shade600.withOpacity(0.4),
                          petals: 20,
                          radiusScale: 0.8,
                        ),
                      ),
                    );
                  },
                ),

                // THE DIVINE VIEWPORT (ETHEREAL DEPTH TRANSITION)
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: baseSize * 0.5,
                    height: baseSize * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange.shade200, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade900.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 2000),
                        switchInCurve: Curves.easeInOutSine,
                        switchOutCurve: Curves.easeInOutSine,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          final zoomIn = Tween<double>(begin: 1.2, end: 1.0).animate(animation);
                          final zoomOut = Tween<double>(begin: 0.8, end: 1.0).animate(animation);
                          
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: child.key == ValueKey(_currentImageIndex) ? zoomIn : zoomOut,
                              child: child,
                            ),
                          );
                        },
                        child: KenBurnsImage(
                          key: ValueKey(_currentImageIndex),
                          imagePath: widget.images[_currentImageIndex],
                        ),
                      ),
                    ),
                  ),
                ),

                // Centered Small Om
                IgnorePointer(
                  child: Container(
                    width: baseSize * 0.15,
                    height: baseSize * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'ॐ',
                        style: TextStyle(
                          fontSize: baseSize * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ),
                ),

                // 5. SACRED HEADER (Ethereal Animation at the Top)
                Positioned(
                  top: baseSize * 0.02,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final provider = Provider.of<LanguageProvider>(context);
                      final lang = provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English';
                      
                      return Opacity(
                        opacity: ((_pulseAnimation.value - 0.98) * 20 + 0.5).clamp(0.0, 1.0), // Clamped pulse
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                TranslationService().translate('book_divine_ritual', lang),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.orange.shade800,
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.orange.withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 60,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.orange.shade700,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 6. SACRED GUIDE (Breathing Downward Arrow)
                Positioned(
                  top: (MediaQuery.of(context).size.height / 2) + (baseSize * 0.45) + 20,
                  child: AnimatedBuilder(
                    animation: _guideController,
                    builder: (context, child) {
                      final provider = Provider.of<LanguageProvider>(context);
                      final lang = provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English';

                      return Column(
                        children: [
                          Text(
                            TranslationService().translate('descend_to_explore', lang),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Transform.translate(
                            offset: Offset(0, _guideSlideAnimation.value),
                            child: Opacity(
                              opacity: _guideOpacityAnimation.value,
                              child: Icon(
                                Icons.keyboard_double_arrow_down_rounded,
                                color: Colors.orange.shade800,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
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

class KenBurnsImage extends StatefulWidget {
  final String imagePath;
  const KenBurnsImage({super.key, required this.imagePath});

  @override
  State<KenBurnsImage> createState() => _KenBurnsImageState();
}

class _KenBurnsImageState extends State<KenBurnsImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Image.asset(
        widget.imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class MandalaPainter extends CustomPainter {
  final Color color;
  final int petals;
  final double radiusScale;

  MandalaPainter({required this.color, required this.petals, required this.radiusScale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * radiusScale;

    for (int i = 0; i < petals; i++) {
      final angle = (2 * math.pi / petals) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), radius / 3, paint);
      
      final nextAngle = (2 * math.pi / petals) * (i + 1);
      final nextX = center.dx + radius * math.cos(nextAngle);
      final nextY = center.dy + radius * math.sin(nextAngle);
      
      final path = Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(center.dx, center.dy, nextX, nextY);
      canvas.drawPath(path, paint);
    }
    
    canvas.drawCircle(center, radius, paint..strokeWidth = 0.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
