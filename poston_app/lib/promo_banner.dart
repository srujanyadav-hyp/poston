import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String discountValue;
  final String discountText;
  final String buttonText;
  final String? buttonLink;
  final String? backgroundImageUrl;
  final String? iconImageUrl; // Dynamic transparent icon

  const PromoBanner({
    super.key,
    this.title = "Special Darshan Offers",
    this.subtitle = "Premium Darshan & Pooja",
    this.discountValue = "30%",
    this.discountText = "OFF",
    this.buttonText = "Book Now",
    this.buttonLink,
    this.backgroundImageUrl,
    this.iconImageUrl,
  });

  Future<void> _launchUrl() async {
    if (buttonLink != null && buttonLink!.isNotEmpty) {
      final url = Uri.parse(buttonLink!);
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child:
                  backgroundImageUrl != null && backgroundImageUrl!.isNotEmpty
                  ? Image.network(backgroundImageUrl!, fit: BoxFit.cover)
                  : Image.asset(
                      'assets/images/venkateswara.jpg',
                      fit: BoxFit.cover,
                    ),
            ),
            // Overlay for better text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // LEFT SIDE
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (buttonText.isNotEmpty)
                          ElevatedButton(
                            onPressed: _launchUrl,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 5,
                              shadowColor: Colors.black26,
                            ),
                            child: Text(
                              buttonText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // RIGHT SIDE
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (discountValue.isNotEmpty)
                          Text(
                            discountValue,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        if (discountText.isNotEmpty)
                          Text(
                            discountText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
