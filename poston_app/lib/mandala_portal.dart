import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:async';
import 'ritual_booking_screen.dart';
import 'language_provider.dart';
import 'translation_service.dart';

class RadiantMandalaPortal extends StatefulWidget {
  final List<String> images;
  final VoidCallback? onArrowTap;
  const RadiantMandalaPortal({super.key, required this.images, this.onArrowTap});

  @override
  State<RadiantMandalaPortal> createState() => _RadiantMandalaPortalState();
}

class _RadiantMandalaPortalState extends State<RadiantMandalaPortal>
    with TickerProviderStateMixin {
  int _outgoingIndex = 0;
  int _incomingIndex = 1;
  bool _isCrossfading = false;
  Timer? _imageTimer;

  late AnimationController _crossfadeCtrl;
  late Animation<double> _crossfadeOpacity;

  late AnimationController _shimmerController;
  late AnimationController _arrowController;
  late AnimationController _badgeController;
  late Animation<double> _shimmer;
  late Animation<double> _arrowBounce;
  late Animation<double> _arrowOpacity;
  late Animation<double> _badgePulse;

  @override
  void initState() {
    super.initState();

    _crossfadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _crossfadeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _crossfadeCtrl, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _arrowBounce = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
    _arrowOpacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _badgePulse = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeInOut),
    );

    _startImageCycle();
  }

  void _startImageCycle() {
    _imageTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || _isCrossfading) return;
      _triggerCrossfade();
    });
  }

  void _triggerCrossfade() {
    final nextIndex = (_outgoingIndex + 1) % widget.images.length;
    setState(() {
      _incomingIndex = nextIndex;
      _isCrossfading = true;
    });
    _crossfadeCtrl.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _outgoingIndex = nextIndex;
        _isCrossfading = false;
      });
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _crossfadeCtrl.dispose();
    _shimmerController.dispose();
    _arrowController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  void _navigateToBooking() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, _) => const RitualBookingScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).selectedLanguages.firstOrNull ?? 'English';
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // ── LAYER 1: Dual-layer seamless crossfade ──
          _KenBurnsBackground(
            key: ValueKey('out_$_outgoingIndex'),
            imagePath: widget.images[_outgoingIndex],
          ),
          if (_isCrossfading)
            FadeTransition(
              opacity: _crossfadeOpacity,
              child: _KenBurnsBackground(
                key: ValueKey('in_$_incomingIndex'),
                imagePath: widget.images[_incomingIndex],
              ),
            ),

          // ── LAYER 2: Cinematic Gradient Scrim ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.3, 0.6, 1.0],
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.88),
                ],
              ),
            ),
          ),

          // ── LAYER 3: Background tap zones (Translucent) ──
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _navigateToBooking,
                    behavior: HitTestBehavior.translucent,
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 110), // Protect the arrow area from background booking taps
              ],
            ),
          ),

          // ── LAYER 4: Top Brand Strip ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedBuilder(
                    animation: _badgePulse,
                    builder: (context, _) => Opacity(
                      opacity: _badgePulse.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LIVE RITUALS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(widget.images.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _outgoingIndex ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _outgoingIndex
                              ? Colors.orangeAccent
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // ── LAYER 5: Bottom Content Card ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.92),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.7)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'SACRED RITUALS & PUJA',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    TranslationService().translate('book_divine_ritual', lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: -0.5,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _shimmer,
                    builder: (context, _) {
                      return ShaderMask(
                        shaderCallback: (rect) => LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [
                            (_shimmer.value - 0.4).clamp(0.0, 1.0),
                            _shimmer.value.clamp(0.0, 1.0),
                            (_shimmer.value + 0.4).clamp(0.0, 1.0),
                          ],
                          colors: const [
                            Color(0xFFE65C00),
                            Color(0xFFFFD700),
                            Color(0xFFE65C00),
                          ],
                        ).createShader(rect),
                        child: Container(
                          height: 2,
                          width: 120,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _navigateToBooking,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9933), Color(0xFFE65C00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE65C00).withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            TranslationService().translate('book_a_ritual', lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      
                      // Bouncing Down Arrow integrated into Row
                      GestureDetector(
                        onTap: widget.onArrowTap,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedBuilder(
                          animation: _arrowController,
                          builder: (context, _) => Opacity(
                            opacity: _arrowOpacity.value,
                            child: Transform.translate(
                              offset: Offset(0, _arrowBounce.value),
                              child: const Icon(
                                Icons.keyboard_double_arrow_down_rounded,
                                color: Colors.orangeAccent,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KenBurnsBackground extends StatelessWidget {
  final String imagePath;
  const _KenBurnsBackground({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
      ),
    );
  }
}
