import 'dart:io';
// import 'upi_payment_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'package:translator/translator.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'translation_service.dart';

class EarnWithUsScreen extends StatefulWidget {
  const EarnWithUsScreen({super.key});

  @override
  State<EarnWithUsScreen> createState() => _EarnWithUsScreenState();
}

class _EarnWithUsScreenState extends State<EarnWithUsScreen> {
  final _serviceFormKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subHeadingController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _mapLinkController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  
  String _selectedCategory = 'Temple Information';
  File? _serviceImageFile;
  bool _isServiceLoading = false;
  bool _isCategoryExpanded = false;

  final List<String> _categories = [
    'Temple Information',
    'Parking',
    'Petrol Bunks',
    'Cabs and Travels',
    'Hotels',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subHeadingController.dispose();
    _descController.dispose();
    _mapLinkController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickServiceImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _serviceImageFile = File(image.path);
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _submitServiceData() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    
    // 1. If not logged in, go to Login Screen
    if (currentUser == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    if (!_serviceFormKey.currentState!.validate()) return;
    if (_serviceImageFile == null) {
      _showError('Please select a service image first');
      return;
    }

    setState(() => _isServiceLoading = true);

    /*
    // REQUIRE PAYMENT FIRST (SKIPPED FOR NOW)
    final success = await UpiPaymentService.initiatePayment(
      amount: 1.0, // Listing fee
      transactionId: 'LIST${DateTime.now().millisecondsSinceEpoch}',
      transactionNote: 'Service Listing Fee',
    );

    if (!success) {
      _showError('Payment failed or cancelled. Listing aborted.');
      if (mounted) setState(() => _isServiceLoading = false);
      return;
    }
    */

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
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_serviceImageFile!.path.split('/').last}';
      await Supabase.instance.client.storage
          .from('poston_images')
          .upload(fileName, _serviceImageFile!);

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
        _serviceImageFile = null;
      });
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isServiceLoading = false);
    }
  }

  Future<void> _deleteService(String id, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final uri = Uri.parse(imageUrl);
        final fileName = uri.pathSegments.last;
        await Supabase.instance.client.storage
            .from('poston_images')
            .remove([fileName]);
      }
      await Supabase.instance.client.from('service_items').delete().eq('id', id);
      _showSuccess('Service deleted successfully');
      setState(() {});
    } catch (e) {
      _showError('Error deleting service: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context);
    final lang = provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      appBar: AppBar(
        backgroundColor: Colors.orange.shade800,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          TranslationService().translate('earn_with_us', lang),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/OM-Symbol.png'),
            fit: BoxFit.scaleDown,
            colorFilter: ColorFilter.mode(Color(0x33FFB74D), BlendMode.dstATop),
          ),
        ),
        child: _buildAddServiceTab(lang),
      ),
    );
  }

  Widget _buildAddServiceTab(String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _serviceFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              TranslationService().translate('partner_with_us', lang),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              TranslationService().translate('list_service_desc', lang),
              style: TextStyle(color: Colors.brown.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Image Picker
            GestureDetector(
              onTap: _pickServiceImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _serviceImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_serviceImageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.orange.shade300),
                          const SizedBox(height: 10),
                          Text(
                            TranslationService().translate('upload_service_photo', lang),
                            style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            _buildInputField(
              controller: _titleController,
              label: TranslationService().translate('service_title', lang),
              icon: Icons.title,
              lang: lang,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _subHeadingController,
              label: TranslationService().translate('price_subheading', lang),
              icon: Icons.currency_rupee,
              lang: lang,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _descController,
              label: TranslationService().translate('description', lang),
              icon: Icons.description,
              maxLines: 3,
              lang: lang,
            ),
            const SizedBox(height: 16),
            
            // Category Dropdown (Inline Premium Accordion)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _isCategoryExpanded ? Colors.orange.shade800 : Colors.orange.shade200,
                  width: _isCategoryExpanded ? 2 : 1,
                ),
                boxShadow: _isCategoryExpanded
                    ? [BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
                    : [],
              ),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      setState(() {
                        _isCategoryExpanded = !_isCategoryExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.category, color: _isCategoryExpanded ? Colors.orange.shade800 : Colors.orange.shade300),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              TranslationService().translate(_selectedCategory.toLowerCase().replaceAll(' ', '_'), lang),
                              style: TextStyle(
                                fontSize: 16, 
                                color: Colors.brown.shade800,
                                fontWeight: _isCategoryExpanded ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isCategoryExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(Icons.keyboard_arrow_down, color: _isCategoryExpanded ? Colors.orange.shade800 : Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity, height: 0),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Divider(height: 1, color: Colors.orange.shade100),
                        ..._categories.map((String category) {
                          final isSelected = category == _selectedCategory;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                                _isCategoryExpanded = false;
                              });
                            },
                            child: Container(
                              color: isSelected ? Colors.orange.shade50 : Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      TranslationService().translate(category.toLowerCase().replaceAll(' ', '_'), lang),
                                      style: TextStyle(
                                        color: isSelected ? Colors.orange.shade800 : Colors.brown.shade700,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle, color: Colors.orange.shade600, size: 20),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    ),
                    crossFadeState: _isCategoryExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                    sizeCurve: Curves.easeInOut,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: _mapLinkController,
              label: TranslationService().translate('google_maps_link', lang),
              icon: Icons.map,
              isRequired: false,
              lang: lang,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _latitudeController,
                    label: TranslationService().translate('latitude', lang),
                    icon: Icons.location_on,
                    isRequired: false,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    lang: lang,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    controller: _longitudeController,
                    label: TranslationService().translate('longitude', lang),
                    icon: Icons.location_on,
                    isRequired: false,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    lang: lang,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            _isServiceLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : ElevatedButton(
                    onPressed: _submitServiceData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      TranslationService().translate('list_service_button', lang),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String lang,
    bool isRequired = true,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '${TranslationService().translate('please_enter', lang)} $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange.shade300),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.orange.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.orange.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.orange.shade800, width: 2),
        ),
      ),
    );
  }
}
