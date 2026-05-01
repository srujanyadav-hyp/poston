import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'notification_service.dart';
import 'translation_helper.dart';
import 'language_provider.dart';
import 'translation_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // --- Service Upload State ---
  final _serviceFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(); // Heading
  final _subHeadingController =
      TextEditingController(); // Sub heading (mapped to price/subtitle)
  final _descController = TextEditingController();
  final _mapLinkController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  String _selectedCategory = 'Temple Information';
  final List<String> _categories = [
    'Temple Information',
    'Tirupati',
    'Sabarimala',
    'Cabs and Travels',
    'Hotels',
    'Parking',
    'Petrol Bunks',
    'Earn with us',
    'Contact and chat',
  ];

  Uint8List? _serviceImageBytes;
  String? _serviceImageFileName;
  bool _isServiceLoading = false;

  // --- Banner Upload State ---
  final _bannerFormKey = GlobalKey<FormState>();
  final _bannerTitleController = TextEditingController();
  final _bannerSubtitleController = TextEditingController();
  final _bannerDiscountValueController = TextEditingController();
  final _bannerDiscountTextController = TextEditingController();
  final _bannerButtonTextController = TextEditingController();
  final _bannerButtonLinkController = TextEditingController();

  Uint8List? _bannerBgBytes;
  String? _bannerBgFileName;
  Uint8List? _bannerIconBytes;
  String? _bannerIconFileName;
  bool _isBannerLoading = false;

  // --- Notification State ---
  final _notifTitleController = TextEditingController();
  final _notifMessageController = TextEditingController();
  bool _isSendingNotif = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subHeadingController.dispose();
    _descController.dispose();
    _mapLinkController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _bannerTitleController.dispose();
    _bannerSubtitleController.dispose();
    _bannerDiscountValueController.dispose();
    _bannerDiscountTextController.dispose();
    _bannerButtonTextController.dispose();
    _bannerButtonLinkController.dispose();
    _notifTitleController.dispose();
    _notifMessageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({
    required bool isService,
    bool isBannerIcon = false,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (isService) {
          _serviceImageBytes = bytes;
          _serviceImageFileName = pickedFile.name;
        } else {
          if (isBannerIcon) {
            _bannerIconBytes = bytes;
            _bannerIconFileName = pickedFile.name;
          } else {
            _bannerBgBytes = bytes;
            _bannerBgFileName = pickedFile.name;
          }
        }
      });
    }
  }

  Future<void> _submitServiceData() async {
    if (!_serviceFormKey.currentState!.validate()) return;
    if (_serviceImageBytes == null || _serviceImageFileName == null) {
      _showError('Please select a service image first');
      return;
    }

    setState(() => _isServiceLoading = true);

    // Get latitude and longitude from manual input
    double? lat;
    double? lng;
    
    final latStr = _latitudeController.text.trim();
    final lngStr = _longitudeController.text.trim();
    
    if (latStr.isNotEmpty && lngStr.isNotEmpty) {
      lat = double.tryParse(latStr);
      lng = double.tryParse(lngStr);
      
      if (lat == null || lng == null) {
        if (mounted) setState(() => _isServiceLoading = false);
        _showError('Please enter valid latitude and longitude values');
        return;
      }
    } else if (latStr.isNotEmpty || lngStr.isNotEmpty) {
      if (mounted) setState(() => _isServiceLoading = false);
      _showError('Please enter both latitude and longitude');
      return;
    }
    
    String mapLink = _mapLinkController.text.trim();

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$_serviceImageFileName';
      await Supabase.instance.client.storage
          .from('poston_images')
          .uploadBinary(fileName, _serviceImageBytes!);

      final imageUrl = Supabase.instance.client.storage
          .from('poston_images')
          .getPublicUrl(fileName);

      final translator = GoogleTranslator();
      
      // Auto-Translate title
      final titleEn = _titleController.text.trim();
      final titleTe = (await translator.translate(titleEn, to: 'te')).text;
      final titleHi = (await translator.translate(titleEn, to: 'hi')).text;
      final titleTa = (await translator.translate(titleEn, to: 'ta')).text;
      final titleKn = (await translator.translate(titleEn, to: 'kn')).text;

      // Auto-Translate price/subtitle
      final priceEn = _subHeadingController.text.trim();
      final priceTe = (await translator.translate(priceEn, to: 'te')).text;
      final priceHi = (await translator.translate(priceEn, to: 'hi')).text;
      final priceTa = (await translator.translate(priceEn, to: 'ta')).text;
      final priceKn = (await translator.translate(priceEn, to: 'kn')).text;

      // Auto-Translate description
      final descEn = _descController.text.trim();
      final descTe = (await translator.translate(descEn, to: 'te')).text;
      final descHi = (await translator.translate(descEn, to: 'hi')).text;
      final descTa = (await translator.translate(descEn, to: 'ta')).text;
      final descKn = (await translator.translate(descEn, to: 'kn')).text;

      await Supabase.instance.client.from('service_items').insert({
        'category': _selectedCategory,
        'title': titleEn,
        'title_te': titleTe,
        'title_hi': titleHi,
        'title_ta': titleTa,
        'title_kn': titleKn,
        'price': priceEn,
        'price_te': priceTe,
        'price_hi': priceHi,
        'price_ta': priceTa,
        'price_kn': priceKn,
        'description': descEn,
        'description_te': descTe,
        'description_hi': descHi,
        'description_ta': descTa,
        'description_kn': descKn,
        'image_url': imageUrl,
        'map_link': mapLink.isNotEmpty ? mapLink : null,
        'latitude': lat,
        'longitude': lng,
      });

      _showSuccess('Service uploaded successfully!');
      _titleController.clear();
      _subHeadingController.clear();
      _descController.clear();
      _mapLinkController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      setState(() {
        _serviceImageBytes = null;
        _serviceImageFileName = null;
      });
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isServiceLoading = false);
    }
  }

  Future<void> _submitBannerData() async {
    if (!_bannerFormKey.currentState!.validate()) return;
    if (_bannerBgBytes == null || _bannerBgFileName == null) {
      _showError('Please select a background image for the banner');
      return;
    }

    setState(() => _isBannerLoading = true);

    try {
      // 1. Upload Banner BG
      final bgFileName =
          'banner_bg_${DateTime.now().millisecondsSinceEpoch}_$_bannerBgFileName';
      await Supabase.instance.client.storage
          .from('poston_images')
          .uploadBinary(bgFileName, _bannerBgBytes!);
      final bgImageUrl = Supabase.instance.client.storage
          .from('poston_images')
          .getPublicUrl(bgFileName);

      // 2. Upload Banner Icon (Optional)
      String? iconUrl;
      if (_bannerIconBytes != null && _bannerIconFileName != null) {
        final iconFileName =
            'banner_icon_${DateTime.now().millisecondsSinceEpoch}_$_bannerIconFileName';
        await Supabase.instance.client.storage
            .from('poston_images')
            .uploadBinary(iconFileName, _bannerIconBytes!);
        iconUrl = Supabase.instance.client.storage
            .from('poston_images')
            .getPublicUrl(iconFileName);
      }

      final translator = GoogleTranslator();

      // Translate Title
      final titleEn = _bannerTitleController.text.trim();
      final titleTe = titleEn.isNotEmpty ? (await translator.translate(titleEn, to: 'te')).text : '';
      final titleHi = titleEn.isNotEmpty ? (await translator.translate(titleEn, to: 'hi')).text : '';
      final titleTa = titleEn.isNotEmpty ? (await translator.translate(titleEn, to: 'ta')).text : '';
      final titleKn = titleEn.isNotEmpty ? (await translator.translate(titleEn, to: 'kn')).text : '';

      // Translate Subtitle
      final subtitleEn = _bannerSubtitleController.text.trim();
      final subtitleTe = subtitleEn.isNotEmpty ? (await translator.translate(subtitleEn, to: 'te')).text : '';
      final subtitleHi = subtitleEn.isNotEmpty ? (await translator.translate(subtitleEn, to: 'hi')).text : '';
      final subtitleTa = subtitleEn.isNotEmpty ? (await translator.translate(subtitleEn, to: 'ta')).text : '';
      final subtitleKn = subtitleEn.isNotEmpty ? (await translator.translate(subtitleEn, to: 'kn')).text : '';

      final discountTextEn = _bannerDiscountTextController.text.trim();
      final buttonTextEn = _bannerButtonTextController.text.trim();

      // 3. Insert into promo_banners
      await Supabase.instance.client.from('promo_banners').insert({
        'title': titleEn,
        'title_te': titleTe,
        'title_hi': titleHi,
        'title_ta': titleTa,
        'title_kn': titleKn,
        'subtitle': subtitleEn,
        'subtitle_te': subtitleTe,
        'subtitle_hi': subtitleHi,
        'subtitle_ta': subtitleTa,
        'subtitle_kn': subtitleKn,
        'discount_value': _bannerDiscountValueController.text.trim(),
        'discount_text': discountTextEn,
        'button_text': buttonTextEn,
        'button_link': _bannerButtonLinkController.text.trim(),
        'bg_image_url': bgImageUrl,
        'icon_url': iconUrl,
      });

      _showSuccess('Promo Banner uploaded successfully!');
      _bannerTitleController.clear();
      _bannerSubtitleController.clear();
      _bannerDiscountValueController.clear();
      _bannerDiscountTextController.clear();
      _bannerButtonTextController.clear();
      _bannerButtonLinkController.clear();
      setState(() {
        _bannerBgBytes = null;
        _bannerBgFileName = null;
        _bannerIconBytes = null;
        _bannerIconFileName = null;
      });
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isBannerLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) => DefaultTabController(
        length: 6,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              TranslationService().translate('admin_panel', languageProvider.selectedLanguages.isNotEmpty ? languageProvider.selectedLanguages.first : 'English'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.orange),
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Colors.orange,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.white,
              tabs: [
                Tab(text: TranslationService().translate('add_service', languageProvider.selectedLanguages.isNotEmpty ? languageProvider.selectedLanguages.first : 'English')),
                Tab(text: TranslationService().translate('manage_services', languageProvider.selectedLanguages.isNotEmpty ? languageProvider.selectedLanguages.first : 'English')),
                Tab(text: TranslationService().translate('add_promo_banner', languageProvider.selectedLanguages.isNotEmpty ? languageProvider.selectedLanguages.first : 'English')),
                Tab(text: TranslationService().translate('manage_banners', languageProvider.selectedLanguages.isNotEmpty ? languageProvider.selectedLanguages.first : 'English')),
                Tab(text: TranslationService().translate('rituals', languageProvider.selectedLanguages.isNotEmpty ? languageProvider.selectedLanguages.first : 'English')),
                Tab(text: TranslationService().translate('notifications', languageProvider.selectedLanguages.isNotEmpty ? languageProvider.selectedLanguages.first : 'English')),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/hanuman.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: TabBarView(
                children: [
                  _buildServiceTab(),
                  _buildManageServicesTab(),
                  _buildBannerTab(),
                  _buildManageBannersTab(),
                  _buildRitualBookingsTab(),
                  _buildNotificationTab(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteRecord(String table, dynamic id) async {
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    final confirmText = TranslationService().translate('confirm_delete_msg', provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English');
    final titleText = TranslationService().translate('confirm_delete_title', provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English');
    final cancelText = TranslationService().translate('cancel', provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English');
    final deleteText = TranslationService().translate('delete', provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English');
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titleText),
        content: Text(confirmText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelText)),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(deleteText, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      debugPrint('Deleting from $table with id: $id (type: ${id.runtimeType})');
      final response = await Supabase.instance.client
          .from(table)
          .delete()
          .eq('id', id);
      debugPrint('Delete response: $response');
      if (mounted) {
        final successMsg = TranslationService().translate('item_deleted', provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English');
        _showSuccess(successMsg);
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      if (mounted) {
        final errorMsg = TranslationService().translate('error_deleting', provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English');
        _showError('$errorMsg$e');
      }
    }
  }

  Widget _buildManageServicesTab() {
    return Consumer<LanguageProvider>(
      builder: (context, provider, _) => StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('service_items').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            final noServicesText = TranslationService().translate('no_services', provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English');
            return Center(child: Text(noServicesText, style: const TextStyle(color: Colors.white, fontSize: 18)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                color: Colors.white.withValues(alpha: 0.9),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: item['image_url'] != null ? NetworkImage(item['image_url']) : null,
                    backgroundColor: Colors.orange.shade100,
                    child: item['image_url'] == null ? const Icon(Icons.image, color: Colors.orange) : null,
                  ),
                  title: Text(item['title'] ?? 'No Title'),
                  subtitle: Text('${item['category']} | ${item['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (item['id'] != null) {
                        _deleteRecord('service_items', item['id']);
                      } else {
                        final unableText = TranslationService().translate('unable_to_delete', provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English');
                        _showError(unableText);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildManageBannersTab() {
    return Consumer<LanguageProvider>(
      builder: (context, provider, _) => StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('promo_banners').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            final noBannersText = TranslationService().translate('no_banners', provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English');
            return Center(child: Text(noBannersText, style: const TextStyle(color: Colors.white, fontSize: 18)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                color: Colors.white.withValues(alpha: 0.9),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: item['bg_image_url'] != null ? NetworkImage(item['bg_image_url']) : null,
                    backgroundColor: Colors.orange.shade100,
                    child: item['bg_image_url'] == null ? const Icon(Icons.image, color: Colors.orange) : null,
                  ),
                  title: Text(item['title'] ?? 'No Title'),
                  subtitle: Text(item['subtitle'] ?? 'No Subtitle'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (item['id'] != null) {
                        _deleteRecord('promo_banners', item['id']);
                      } else {
                        final unableText = TranslationService().translate('unable_to_delete', provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English');
                        _showError(unableText);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceTab() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _serviceFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Which Service?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                  decoration: _inputDeco(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDeco('Heading (e.g. Ganesh Pooja)'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subHeadingController,
                  decoration: _inputDeco('Sub-heading (or Price)'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: _inputDeco('Description'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mapLinkController,
                  decoration: _inputDeco('Map Link (Optional)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _latitudeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: _inputDeco('Latitude (e.g. 13.1939)'),
                  validator: (val) {
                    if (val == null || val.isEmpty) return null;
                    if (double.tryParse(val) == null) return 'Enter valid latitude';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: _inputDeco('Longitude (e.g. 79.1941)'),
                  validator: (val) {
                    if (val == null || val.isEmpty) return null;
                    if (double.tryParse(val) == null) return 'Enter valid longitude';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload Image:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildImagePickerBox(
                  bytes: _serviceImageBytes,
                  onTap: () => _pickImage(isService: true),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isServiceLoading ? null : _submitServiceData,
                    style: _btnStyle(),
                    child: _isServiceLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Upload Service',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerTab() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _bannerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Banner Title:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bannerTitleController,
                  decoration: _inputDeco('e.g. Special Darshan Offers'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Banner Subtitle:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bannerSubtitleController,
                  decoration: _inputDeco('e.g. Premium Darshan & Pooja'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Discount Value:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bannerDiscountValueController,
                  decoration: _inputDeco('e.g. 30%'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Discount Text:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bannerDiscountTextController,
                  decoration: _inputDeco('e.g. OFF'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Button Text:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bannerButtonTextController,
                  decoration: _inputDeco('e.g. Book Now'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Button Link (Optional):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bannerButtonLinkController,
                  decoration: _inputDeco('e.g. https://...'),
                ),
                const SizedBox(height: 16),

                // Background Image
                const Text(
                  'Background Image (Required):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildImagePickerBox(
                  bytes: _bannerBgBytes,
                  onTap: () =>
                      _pickImage(isService: false, isBannerIcon: false),
                ),
                const SizedBox(height: 16),

                // Icon Image
                const Text(
                  'Transparent Icon Image (Optional):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildImagePickerBox(
                  bytes: _bannerIconBytes,
                  onTap: () => _pickImage(isService: false, isBannerIcon: true),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isBannerLoading ? null : _submitBannerData,
                    style: _btnStyle(),
                    child: _isBannerLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Upload Banner',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco([String? label]) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildRitualBookingsTab() {
    return Consumer<LanguageProvider>(
      builder: (context, provider, _) => StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('ritual_bookings')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No Ritual Bookings Yet.', style: TextStyle(color: Colors.white, fontSize: 18)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                color: Colors.white.withValues(alpha: 0.95),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade800,
                    child: const Icon(Icons.temple_hindu, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    item['ritual_name'] ?? 'Unknown Ritual',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    '${item['name']} | ${item['temple_name']}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRitualDetailRow(Icons.person, 'Devotee', item['name']),
                          _buildRitualDetailRow(Icons.phone, 'Contact', item['contact_number']),
                          _buildRitualDetailRow(Icons.email, 'Email', item['user_email']),
                          _buildRitualDetailRow(Icons.temple_hindu, 'Temple', item['temple_name']),
                          _buildRitualDetailRow(Icons.calendar_today, 'Date', item['created_at'].toString().substring(0, 10)),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _deleteRecord('ritual_bookings', item['id']),
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRitualDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.orange.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildNotificationTab() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send Notification to Premium Users',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange),
              ),
              const SizedBox(height: 8),
              const Text(
                'This message will ONLY be sent to users with a Premium subscription.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _notifTitleController,
                decoration: _inputDeco('Notification Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notifMessageController,
                maxLines: 4,
                decoration: _inputDeco('Message Body'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSendingNotif ? null : _sendPremiumNotification,
                  style: _btnStyle(),
                  child: _isSendingNotif
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Send to Premium Users',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendPremiumNotification() async {
    final title = _notifTitleController.text.trim();
    final message = _notifMessageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      _showError('Please enter both a title and a message.');
      return;
    }

    setState(() => _isSendingNotif = true);

    try {
      // 1. Fetch only PREMIUM users from user_roles
      final List<dynamic> premiumUsers = await Supabase.instance.client
          .from('user_roles')
          .select('email, fcm_token')
          .eq('is_premium', true);

      // 2. Filter out users without tokens
      final List<String> tokens = premiumUsers
          .where((user) => user['fcm_token'] != null)
          .map((user) => user['fcm_token'] as String)
          .toList();

      if (tokens.isEmpty) {
        _showError('No premium users with active device tokens found.');
        return;
      }

      // 3. Trigger the real FCM send
      await NotificationService.sendToTokens(
        tokens: tokens,
        title: title,
        body: message,
      );

      _showSuccess('Successfully sent to ${tokens.length} Premium Users!');
      _notifTitleController.clear();
      _notifMessageController.clear();
      
    } catch (e) {
      _showError('Error sending notification: $e');
    } finally {
      if (mounted) setState(() => _isSendingNotif = false);
    }
  }

  Widget _buildImagePickerBox({
    required Uint8List? bytes,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: bytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(bytes, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cloud_upload, size: 40, color: Colors.orange),
                  SizedBox(height: 8),
                  Text(
                    'Tap to select an image from Gallery',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }
}
