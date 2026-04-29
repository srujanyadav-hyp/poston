import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';
import 'promo_banner.dart';
import 'location_utils.dart';
import 'language_provider.dart';
import 'translation_service.dart';
import 'language_selection_screen.dart';
import 'astrology_subscription_screen.dart';
import 'earn_with_us_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sifkyueyowfwiajdrpmv.supabase.co',
    anonKey: 'sb_publishable_XOCtc4cszDhlMA3kDaXI2w_LvqOStKc',
  );

  // Initialize translations
  await TranslationService().init();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Listen for auth changes and sync users into user_roles table
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;
    final user = data.session?.user;

    if (event == AuthChangeEvent.signedIn && user != null && user.email != null) {
      try {
        final existingRole = await Supabase.instance.client
            .from('user_roles')
            .select('role')
            .eq('email', user.email!)
            .maybeSingle();

        if (existingRole == null) {
          await Supabase.instance.client.from('user_roles').insert({
            'email': user.email!,
            'role': 'user',
          });
        }
      } catch (e) {
        debugPrint('Error inserting user role: $e');
      }
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
        child: Consumer<LanguageProvider>(
          builder: (context, provider, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Devotion App',
              
              // 🌍 Localization (i18n) Configuration:
              // We use the official Flutter gen-l10n approach (AppLocalizations).
              // These delegates load the generated .arb translation files dynamically.
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              
              // Defines which languages this app formally supports.
              supportedLocales: AppLocalizations.supportedLocales,
              
              // Listens to LanguageProvider to globally switch the app's context.
              // When this changes, all AppLocalizations.of(context) texts instantly rebuild.
              locale: provider.currentLocale,
              
              theme: ThemeData(
                primarySwatch: Colors.orange,
                scaffoldBackgroundColor: Colors.transparent,
              ),
              home: const MainScreen(),
            );
          },
        ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        image: DecorationImage(
          image: AssetImage('assets/images/OM-Symbol.png'),
          fit: BoxFit.scaleDown,
          colorFilter: ColorFilter.mode(Colors.white70, BlendMode.lighten),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _pages[_currentIndex],
        extendBody: true,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 50, right: 50, bottom: 25),
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home, 'home'),
                  _buildNavItem(
                    1,
                    Icons.chat_bubble_outline,
                    Icons.chat_bubble,
                    'chatbot',
                  ),
                  _buildNavItem(
                    2,
                    Icons.person_outline,
                    Icons.person,
                    'profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String labelKey,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Consumer<LanguageProvider>(
          builder: (context, provider, _) {
            final label = labelKey == 'home' ? AppLocalizations.of(context)!.home : (labelKey == 'chatbot' ? AppLocalizations.of(context)!.chatbot : AppLocalizations.of(context)!.profile);
            return Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? Colors.orange : Colors.grey.shade600,
                  size: 24,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class AstrologyNotificationBadge extends StatefulWidget {
  const AstrologyNotificationBadge({super.key});

  @override
  State<AstrologyNotificationBadge> createState() => _AstrologyNotificationBadgeState();
}

class _AstrologyNotificationBadgeState extends State<AstrologyNotificationBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isSun = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat(); // Continuous rotation

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 0.95), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) setState(() { _isSun = !_isSun; });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AstrologySubscriptionScreen()),
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9933), Color(0xFFE65C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
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
                ? const Icon(Icons.wb_sunny, key: ValueKey('sun'), color: Colors.white, size: 22)
                : Transform.flip(
                    flipX: true,
                    key: const ValueKey('moon'),
                    child: const Icon(Icons.brightness_3, color: Colors.white, size: 22),
                  ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> carouselImages = [
    "assets/images/1756780765_unGIE8KKaY.webp",
    "assets/images/sabarimala-share-image.jpg",
    "assets/images/tiruvannamalai-aerial.jpg",
    "assets/images/image.png",
  ];

  List<dynamic> _filteredPlaces = [];
  bool _isSearching = false;
  bool _isLoading = false;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return; 

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runFilter(String enteredKeyword) async {
    if (enteredKeyword.isEmpty) {
      setState(() {
        _filteredPlaces = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=$enteredKeyword&countrycodes=in&limit=10',
    );
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'DevotionApp/1.0'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _filteredPlaces = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      _runFilter(value);
    });
  }

  Future<void> _launchMapsUrl(String query) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open map.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, provider, _) => SafeArea(
        bottom: false,
        child: Column(
          children: [
            // TOP NAVBAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bigger App Logo
                  Image.asset(
                    'assets/images/cropped-New-Logos-Folder.webp',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.temple_hindu,
                        color: Colors.orange,
                        size: 60,
                      );
                    },
                  ),

                  // Icons
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: Colors.black87,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _filteredPlaces = [];
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        icon: const Icon(
                          Icons.language,
                          color: Colors.black87,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LanguageSelectionScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 5),
                      const AstrologyNotificationBadge(),
                      const SizedBox(width: 15),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(
                          Icons.person,
                          color: Colors.orange,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SEARCH BAR
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isSearching ? 60 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _isSearching
                  ? TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.search_hint,
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
                        suffixIcon: _isLoading
                          ? const Center(
                              widthFactor: 1,
                              heightFactor: 1,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.orange,
                                ),
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // CAROUSEL OR SEARCH RESULTS
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 180,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.9,
                            autoPlayInterval: const Duration(seconds: 4),
                          ),
                          items: carouselImages.map((url) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [Image.asset(url, fit: BoxFit.cover)],
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 25),

                        // Stylish "Famous Temples" Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.famous_temples,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.view_all_small,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Card UI converted and styled for Devotion App Theme
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer<LanguageProvider>(
                            builder: (context, provider, _) => Row(
                              children: [
                                _buildMusicCard(
                                  title: AppLocalizations.of(context)!.venkateswara,
                                  desc: AppLocalizations.of(context)!.tirumala_desc,
                                  imagePath: "assets/images/image.png",
                                  detailImagePath:
                                      "assets/images/venkateswara.jpg",
                                ),
                                const SizedBox(width: 16),
                                _buildMusicCard(
                                  title: AppLocalizations.of(context)!.sabarimala,
                                  desc: AppLocalizations.of(context)!.ayyappa_desc,
                                  imagePath:
                                      "assets/images/sabarimala-share-image.jpg",
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: Supabase.instance.client
                              .from('promo_banners')
                              .stream(primaryKey: ['id'])
                              .order('created_at', ascending: false)
                              .limit(5),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              // By default, if nothing is configured in the admin panel, show the static fallback
                              return CarouselSlider(
                                options: CarouselOptions(
                                  autoPlay: true,
                                  viewportFraction: 1.0,
                                  enlargeCenterPage: false,
                                  height: 160.0,
                                ),
                                items: [
                                  PromoBanner(
                                    title: AppLocalizations.of(context)!.promo_title,
                                    subtitle: AppLocalizations.of(context)!.promo_subtitle,
                                    discountText: AppLocalizations.of(context)!.promo_discount_text,
                                    buttonText: AppLocalizations.of(context)!.promo_button_text,
                                  )
                                ],
                              );
                            }
                            final banners = snapshot.data!;
                            return CarouselSlider(
                              options: CarouselOptions(
                                autoPlay: true,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                height: 160.0,
                                autoPlayInterval: const Duration(seconds: 4),
                              ),
                              items: banners.map((bannerData) {
                                final langCode = provider.currentLocale.languageCode;
                                return PromoBanner(
                                  title: bannerData['title_$langCode'] ?? bannerData['title'] ?? AppLocalizations.of(context)!.promo_title,
                                  subtitle: bannerData['subtitle_$langCode'] ?? bannerData['subtitle'] ?? AppLocalizations.of(context)!.promo_subtitle,
                                  discountValue: bannerData['discount_value'] ?? '',
                                  discountText: bannerData['discount_text'] ?? AppLocalizations.of(context)!.promo_discount_text,
                                  buttonText: bannerData['button_text'] ?? AppLocalizations.of(context)!.promo_button_text,
                                  buttonLink: bannerData['button_link'] ?? '',
                                  backgroundImageUrl: bannerData['bg_image_url'] ?? '',
                                  iconImageUrl: bannerData['icon_url'] ?? '',
                                );
                              }).toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 25),

                        // Our Services Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.our_services,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.view_all_small,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Services Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer<LanguageProvider>(
                            builder: (context, provider, _) => Column(
                              children: [
                                _buildServiceCard(
                                  title: AppLocalizations.of(context)!.temples_info,
                                  category: "Temple Information",
                                  location: AppLocalizations.of(context)!.worldwide_locations,
                                  imageUrl: "assets/images/licensed-image.jpg",
                                ),
                                const SizedBox(height: 12),
                                _buildServiceCard(
                                  title: AppLocalizations.of(context)!.hotels_label,
                                  category: "Hotels",
                                  location: AppLocalizations.of(context)!.find_best_stays,
                                  imageUrl: "assets/images/image copy.png",
                                ),
                                const SizedBox(height: 12),
                                _buildServiceCard(
                                  title: AppLocalizations.of(context)!.cabs_label,
                                  category: "Cabs and Travels",
                                  location: AppLocalizations.of(context)!.book_rides_easily,
                                  imageUrl: "assets/images/cars.jpg",
                                ),
                                const SizedBox(height: 12),
                                _buildServiceCard(
                                  title: AppLocalizations.of(context)!.parking_label,
                                  category: "Parking",
                                  location: AppLocalizations.of(context)!.find_safe_parking,
                                  imageUrl:
                                      "https://media-cdn.tripadvisor.com/media/attractions-splice-spp-674x446/07/03/ef/11.jpg",
                                ),
                                const SizedBox(height: 12),
                                _buildServiceCard(
                                  title: AppLocalizations.of(context)!.petrol_label,
                                  category: "Petrol Bunks",
                                  location: AppLocalizations.of(context)!.locate_fuel_stations,
                                  imageUrl: "assets/images/cars.jpg",
                                ),
                                const SizedBox(height: 12),
                                _buildServiceCard(
                                  title: AppLocalizations.of(context)!.earn_label,
                                  category: "Earn with us",
                                  location: AppLocalizations.of(context)!.join_our_network,
                                  imageUrl: "",
                                  icon: Icons.monetization_on_rounded,
                                  iconColor: Colors.amber.shade600,
                                ),
                                const SizedBox(height: 12),
                                _buildServiceCard(
                                  title: AppLocalizations.of(context)!.contact_label,
                                  category: "Contact and chat",
                                  location: AppLocalizations.of(context)!.support_24_7,
                                  imageUrl: "assets/images/image.png",
                                ),
                              ],
                            ),
                          ),
                      ),

                        const SizedBox(height: 100), // Spacing for bottom nav
                      ],
                    ),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMusicCard({
    required String title,
    required String desc,
    required String imagePath,
    String? detailImagePath,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailPage(
              title: title,
              desc: desc,
              cardImagePath: imagePath,
              backgroundImagePath: detailImagePath ?? imagePath,
            ),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.orange.shade100, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 48, // Guarantees exact same height even if 1 line
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 42, // Guarantees exact same height even if 1 line
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 240,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 140,
                  child: Center(child: Text('Image missing')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String category,
    required String location,
    required String imageUrl,
    IconData? icon,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        if (category == "Earn with us") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EarnWithUsScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailPage(
                title: title,
                category: category,
                location: location,
                imageUrl: imageUrl,
                userPosition: _currentPosition,
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon != null
                ? Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          (iconColor ?? Colors.orange).withValues(alpha: 0.1),
                          (iconColor ?? Colors.orange).withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: (iconColor ?? Colors.orange).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 55,
                        color: iconColor ?? Colors.orange,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            width: 118,
                            height: 118,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 118,
                              height: 118,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Image.asset(
                            imageUrl,
                            width: 118,
                            height: 118,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 118,
                              height: 118,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailPage(
                              title: title,
                              category: category,
                              location: location,
                              imageUrl: imageUrl,
                              userPosition: _currentPosition,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade50,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.view_all_small,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildSearchResults() {
    return Consumer<LanguageProvider>(
      builder: (context, provider, _) {
        if (!_isLoading &&
            _filteredPlaces.isEmpty &&
            _searchController.text.isNotEmpty) {
          return const Center(
            child: Text(
              'No places found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        if (_filteredPlaces.isEmpty) {
          final typeText = AppLocalizations.of(context)!.type_to_search;
          return Center(
            child: Text(
              typeText,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
          itemCount: _filteredPlaces.length,
          itemBuilder: (context, index) {
            final item = _filteredPlaces[index];
            final String displayName = item['display_name'] ?? 'Unknown Place';
            final String type = item['type'] ?? 'Location';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.place, color: Colors.black54),
            ),
            title: Text(
              displayName.split(',').first,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Type: ${type.toUpperCase()}",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions, color: Colors.blue.shade600),
                const SizedBox(height: 2),
                Text(
                  'Map',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            onTap: () {
              _launchMapsUrl(displayName);
            },
          ),
        );
      },
    );
        }
      );
  }
}

class CardDetailPage extends StatelessWidget {
  final String title;
  final String desc;
  final String cardImagePath;
  final String backgroundImagePath;

  const CardDetailPage({
    super.key,
    required this.title,
    required this.desc,
    required this.cardImagePath,
    required this.backgroundImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSabarimala = title.toUpperCase().contains('SABARIMALA');
    final String locationText = isSabarimala
        ? AppLocalizations.of(context)!.sabarimala_loc
        : AppLocalizations.of(context)!.tirumala_loc;
    final String mapQuery = isSabarimala
        ? "Sabarimala,+Kerala"
        : "Tirumala,+Andhra+Pradesh";
    final String websiteUrl = isSabarimala
        ? "https://sabarimala.kerala.gov.in/"
        : "https://ttdevasthanams.ap.gov.in";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(
                alpha: 0.7,
              ), // Darkened slightly for better text contrast
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ), // Better horizontal padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(
                              0,
                              10,
                            ), // Premium floating shadow
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          cardImagePath,
                          width: double.infinity,
                          height:
                              200, // Slightly taller for richer presentation
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    'Image missing',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors
                          .orangeAccent, // Brighter orange for better visibility
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(
                        alpha: 0.9,
                      ), // Improved contrast
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App-Theme Premium Details Section
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 20,
                          children: [
                            _DetailItem(
                              icon: Icons.location_on,
                              text: locationText,
                              onTap: () async {
                                final url = Uri.parse(
                                  "https://maps.google.com/?q=$mapQuery",
                                );
                                try {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } catch (_) {
                                  debugPrint('Could not launch \$url');
                                }
                              },
                            ),
                            _DetailItem(
                              icon: Icons.access_time,
                              text: AppLocalizations.of(context)!.open_daily,
                            ),
                            _DetailItem(
                              icon: Icons.language,
                              text: AppLocalizations.of(context)!.official_website,
                              onTap: () async {
                                final url = Uri.parse(websiteUrl);
                                try {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } catch (_) {
                                  debugPrint('Could not launch \$url');
                                }
                              },
                            ),
                            _DetailItem(
                              icon: Icons.local_activity,
                              text: AppLocalizations.of(context)!.special_darshan,
                            ),
                            _DetailItem(
                              icon: Icons.dry_cleaning,
                              text: AppLocalizations.of(context)!.dress_code,
                              expandableText:
                                  "Men: Dhoti / Shirt / Pants\nWomen: Saree / Chudidar / Traditional Wear",
                            ),
                            _DetailItem(
                              icon: Icons.hotel,
                              text: AppLocalizations.of(context)!.accommodation_available,
                              onTap: () {
                                // Navigate to accommodation page later
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    AppLocalizations.of(context)!.overview,
                    style: TextStyle(
                      fontSize: 24, // Enhanced readability
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppLocalizations.of(context)!.overview_desc,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(
                        alpha: 0.85,
                      ), // Cleaner text
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(
                    height: 48,
                  ), // Nicer spacing before main action button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(
                            0,
                            8,
                          ), // Soft glowing button shadow
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange.shade600, // Premium rich orange
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation:
                            0, // Elevation is handled by container box-shadow
                      ),
                      onPressed: () {},
                      child: Text(
                        AppLocalizations.of(context)!.explore_btn,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2, // Premium feeling
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    AppLocalizations.of(context)!.nearby_temples,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _SimilarTempleCard(
                          templeName: AppLocalizations.of(context)!.kanipakam,
                          subtitle: AppLocalizations.of(context)!.kanipakam_desc,
                          location: AppLocalizations.of(context)!.chittoor,
                          mapQuery: "Kanipakam+Vinayaka+Temple,+Chittoor",
                          imageUrl: "assets/images/kanipakam.webp",
                          colorTheme: Color(0xFFE8F0F9),
                        ),
                        SizedBox(width: 16),
                        _SimilarTempleCard(
                          templeName: AppLocalizations.of(context)!.srikalahasti,
                          subtitle: AppLocalizations.of(context)!.rahu_ketu_pooja,
                          location: AppLocalizations.of(context)!.srikalahasti_loc,
                          mapQuery: "Srikalahasti+Temple",
                          imageUrl: "assets/images/Srikalahasthi-1.webp",
                          colorTheme: Color(0xFFF9E8E8),
                        ),
                        SizedBox(width: 16),
                        _SimilarTempleCard(
                          templeName: AppLocalizations.of(context)!.govindaraja,
                          subtitle: AppLocalizations.of(context)!.vishnu_historic,
                          location: AppLocalizations.of(context)!.tirupati,
                          mapQuery: "Sri+Govindaraja+Swamy+Temple,+Tirupati",
                          imageUrl: "assets/images/govindaraja.jpg",
                          colorTheme: Color(0xFFF2E8F9),
                        ),
                        SizedBox(width: 16),
                        _SimilarTempleCard(
                          templeName: AppLocalizations.of(context)!.kalyana_venkateswara,
                          subtitle: AppLocalizations.of(context)!.marriage_blessings_desc,
                          location: AppLocalizations.of(context)!.srinivasa_mangapuram,
                          mapQuery:
                              "Sri+Kalyana+Venkateswara+Temple,+Srinivasa+Mangapuram",
                          imageUrl: "assets/images/kalyana venketeswara.webp",
                          colorTheme: Color(0xFFF9EFE8),
                        ),
                        SizedBox(width: 16),
                        _SimilarTempleCard(
                          templeName: AppLocalizations.of(context)!.kapila_theertham,
                          subtitle: AppLocalizations.of(context)!.sacred_shiva,
                          location: AppLocalizations.of(context)!.tirupati,
                          mapQuery: "Kapila+Theertham+Temple,+Tirupati",
                          imageUrl: "assets/images/kapali thhertham.webp",
                          colorTheme: Color(0xFFF9E8E8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SimilarTempleCard extends StatelessWidget {
  final String templeName;
  final String subtitle;
  final String location;
  final String imageUrl;
  final Color colorTheme;
  final String mapQuery;

  const _SimilarTempleCard({
    required this.templeName,
    required this.subtitle,
    required this.location,
    required this.imageUrl,
    required this.colorTheme,
    required this.mapQuery,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse("https://maps.google.com/?q=$mapQuery");
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Could not launch $url');
        }
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: colorTheme,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 130,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      imageUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 130,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location row
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 8,
                          backgroundImage: AssetImage(
                            'assets/images/OM-Symbol.png',
                          ), // Placeholder for circular logo
                          backgroundColor: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      templeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final String? expandableText;

  const _DetailItem({
    required this.icon,
    required this.text,
    this.onTap,
    this.expandableText,
  });

  @override
  State<_DetailItem> createState() => _DetailItemState();
}

class _DetailItemState extends State<_DetailItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.expandableText != null
          ? () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          : widget.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            color:
                                widget.onTap != null &&
                                    widget.expandableText == null
                                ? Colors.lightBlueAccent.shade200
                                : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            decoration:
                                widget.onTap != null &&
                                    widget.expandableText == null
                                ? TextDecoration.underline
                                : null,
                            decorationColor: Colors.lightBlueAccent.shade200,
                          ),
                        ),
                      ),
                      if (widget.expandableText != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_isExpanded && widget.expandableText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      widget.expandableText!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceDetailPage extends StatefulWidget {
  final String title;
  final String category;
  final String location;
  final String imageUrl;
  final Position? userPosition;

  const ServiceDetailPage({
    super.key,
    required this.title,
    required this.category,
    required this.location,
    required this.imageUrl,
    this.userPosition,
  });

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  late final Stream<List<Map<String, dynamic>>> _serviceStream;
  List<Map<String, dynamic>> _latestItems = [];
  Position? _resolvedUserPosition;

  @override
  void initState() {
    super.initState();
    _resolvedUserPosition = widget.userPosition;
    if (_resolvedUserPosition == null) {
      _resolveUserPosition();
    }
    _serviceStream = Supabase.instance.client
        .from('service_items')
        .stream(primaryKey: ['id'])
        .eq('category', widget.category)
        .order('created_at', ascending: false);
  }

  Future<void> _resolveUserPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _resolvedUserPosition = position;
      });
    } catch (e) {
      debugPrint('Error resolving user location in detail page: $e');
    }
  }

  double? _getItemDistance(Map<String, dynamic> item) {
    final userPosition = _resolvedUserPosition;
    if (userPosition == null) return null;

    final latitude = parseDoubleValue(item['latitude']);
    final longitude = parseDoubleValue(item['longitude']);
    if (latitude != null && longitude != null) {
      return Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        latitude,
        longitude,
      );
    }

    final mapLink = item['map_link']?.toString();
    if (mapLink != null && mapLink.isNotEmpty) {
      final coordinates = extractGoogleMapsCoordinates(mapLink);
      if (coordinates != null) {
        return Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          coordinates.latitude,
          coordinates.longitude,
        );
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange.shade800,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                contextLocation: widget.location,
                contextCategory: widget.category,
                availableListings: _latestItems,
                initialMessage:
                    "Can you recommend some ${widget.category} around ${widget.location}?",
              ),
            ),
          );
        },
        backgroundColor: Colors.orange.shade800,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.assistant,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF9F2),
          image: DecorationImage(
            image: AssetImage('assets/images/om-symbol.png'),
            fit: BoxFit.scaleDown,
            colorFilter: ColorFilter.mode(Color(0x33FFB74D), BlendMode.dstATop),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 230,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: widget.imageUrl.startsWith('http')
                          ? Image.network(
                              widget.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.orange,
                                  ),
                            )
                          : Image.asset(
                              widget.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.orange,
                                  ),
                            ),
                    ),
                  ),
                ],
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.orange.shade800,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.location,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // About
                    Text(
                      AppLocalizations.of(context)!.about_this_service,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.explore_listings_desc(widget.title),
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Listings Title
                    Text(
                      AppLocalizations.of(context)!.available_listings,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Listings Stream
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _serviceStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.error_outline, size: 40, color: Colors.red.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  "Failed to load listings. Please check your connection.",
                                  style: TextStyle(fontSize: 16, color: Colors.red.shade800),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return const SizedBox.shrink();
                        }

                        final items = List<Map<String, dynamic>>.from(snapshot.data!);

                        final userPosition = _resolvedUserPosition;
                        if (userPosition != null) {
                          for (var item in items) {
                            final distance = _getItemDistance(item);
                            item['distance_m'] = distance ?? double.infinity;
                          }
                          items.sort(
                            (a, b) => (a['distance_m'] as double).compareTo(
                              b['distance_m'] as double,
                            ),
                          );
                        }

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _latestItems = items;
                        });

                        if (items.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 40,
                                  color: Colors.orange,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "No listings available yet.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.orange.shade100,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['title_${Provider.of<LanguageProvider>(context).currentLocale.languageCode}'] ?? item['title'] ?? 'Listing Item',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      if (item['distance_m'] != null && item['distance_m'] != double.infinity)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.green.shade200),
                                          ),
                                          child: Text(
                                            '${(item['distance_m'] / 1000).toStringAsFixed(1)} km',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: Text(
                                            'Distance Uncalculated',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description_${Provider.of<LanguageProvider>(context).currentLocale.languageCode}'] ?? item['description'] ??
                                        'No description provided.',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item['image_url'] ?? '',
                                      width: double.infinity,
                                      height: 160,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, err, stack) =>
                                          Container(
                                            height: 160,
                                            width: double.infinity,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Text('Image missing'),
                                            ),
                                          ),
                                    ),
                                  ),
                                  if (item['map_link'] != null && item['map_link'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Consumer<LanguageProvider>(
                                        builder: (context, provider, _) => ElevatedButton.icon(
                                          onPressed: () async {
                                            final url = Uri.parse(item['map_link']);
                                            try {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                            } catch (_) {
                                              debugPrint('Could not launch map_link');
                                            }
                                          },
                                          icon: const Icon(Icons.map, size: 16),
                                          label: Text(AppLocalizations.of(context)!.view_on_map),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.orange.shade800,
                                            side: BorderSide(color: Colors.orange.shade300),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 80), // extra padding for FAB
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
