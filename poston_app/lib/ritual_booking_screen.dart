import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'translation_service.dart';

class RitualBookingScreen extends StatefulWidget {
  const RitualBookingScreen({super.key});

  @override
  State<RitualBookingScreen> createState() => _RitualBookingScreenState();
}

class _RitualBookingScreenState extends State<RitualBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _templeNameController = TextEditingController();
  final TextEditingController _ritualNameController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFetchingTemples = true;
  List<Map<String, dynamic>> _temples = [];
  List<Map<String, dynamic>> _filteredTemples = [];

  @override
  void initState() {
    super.initState();
    _fetchTemples();
  }

  Future<void> _fetchTemples() async {
    try {
      final response = await Supabase.instance.client
          .from('service_items')
          .select()
          .eq('category', 'Temple Information');
      
      if (mounted) {
        setState(() {
          _temples = List<Map<String, dynamic>>.from(response);
          _filteredTemples = _temples;
          _isFetchingTemples = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching temples: $e');
      if (mounted) setState(() => _isFetchingTemples = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _templeNameController.dispose();
    _ritualNameController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English';

    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      await Supabase.instance.client.from('ritual_bookings').insert({
        'user_id': user?.id,
        'user_email': user?.email,
        'name': _nameController.text.trim(),
        'contact_number': _contactController.text.trim(),
        'temple_name': _templeNameController.text.trim(),
        'ritual_name': _ritualNameController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TranslationService().translate('booking_success', lang)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context);
    final lang = provider.selectedLanguages.isNotEmpty ? provider.selectedLanguages.first : 'English';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      appBar: AppBar(
        title: Text(
          TranslationService().translate('book_a_ritual', lang), 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: Colors.orange.shade800,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/OM-Symbol.png'),
            fit: BoxFit.scaleDown,
            colorFilter: ColorFilter.mode(Color(0x1AEE5C00), BlendMode.dstATop),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(lang),
                const SizedBox(height: 32),
                
                _buildTextField(
                  controller: _nameController,
                  label: TranslationService().translate('your_name', lang),
                  icon: Icons.person_outline,
                  lang: lang,
                ),
                const SizedBox(height: 20),
                
                _buildTextField(
                  controller: _contactController,
                  label: TranslationService().translate('contact_number', lang),
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  lang: lang,
                ),
                const SizedBox(height: 20),

                _buildTempleSelector(lang),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _ritualNameController,
                  label: TranslationService().translate('ritual_name_label', lang),
                  icon: Icons.auto_awesome_outlined,
                  lang: lang,
                ),
                const SizedBox(height: 40),

                _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                  : ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: Colors.orange.withOpacity(0.5),
                      ),
                      child: Text(
                        TranslationService().translate('confirm_booking', lang),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                    ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String lang) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Icon(Icons.temple_hindu, size: 50, color: Colors.orange.shade800),
        ),
        const SizedBox(height: 16),
        Text(
          TranslationService().translate('ritual_booking_header', lang),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          TranslationService().translate('ritual_booking_desc', lang),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.brown, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String lang,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        validator: (value) => value == null || value.isEmpty 
            ? '${TranslationService().translate('please_enter', lang)} $label' 
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.orange.shade700),
          prefixIcon: Icon(icon, color: Colors.orange.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.orange.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.orange.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.orange.shade800, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTempleSelector(String lang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Autocomplete<Map<String, dynamic>>(
        displayStringForOption: (option) => option['title'] ?? '',
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<Map<String, dynamic>>.empty();
          }
          return _temples.where((Map<String, dynamic> option) {
            return option['title']
                .toString()
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (Map<String, dynamic> selection) {
          setState(() {
            _templeNameController.text = selection['title'] ?? '';
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          // Sync manual typing to our controller
          controller.addListener(() {
            _templeNameController.text = controller.text;
          });
          
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            validator: (value) => value == null || value.isEmpty 
                ? TranslationService().translate('select_or_enter_temple', lang) 
                : null,
            decoration: InputDecoration(
              labelText: TranslationService().translate('temple_name_label', lang),
              labelStyle: TextStyle(color: Colors.orange.shade700),
              prefixIcon: Icon(Icons.temple_hindu_outlined, color: Colors.orange.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.orange.shade100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.orange.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.orange.shade800, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: _isFetchingTemples 
                  ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2))) 
                  : null,
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: MediaQuery.of(context).size.width - 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      leading: Icon(Icons.temple_hindu, color: Colors.orange.shade800),
                      title: Text(option['title'] ?? ''),
                      subtitle: Text(option['price'] ?? '', style: const TextStyle(fontSize: 12)),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
