import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'translation_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  final String? contextLocation;
  final String? contextCategory;
  final List<Map<String, dynamic>>? availableListings;
  final String? initialMessage;

  const ChatScreen({
    super.key,
    this.contextLocation,
    this.contextCategory,
    this.availableListings,
    this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  static final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;
  late final ChatSession _chat;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    String basePrompt =
        "You are 'Darshan Bot', a highly helpful assistant for a devotion and temple booking app. "
        "Keep your answers short, concise, and complete (maximum 2-3 sentences). "
        "Do not cut off your sentences midway. Always finish your thoughts. "
        "IMPORTANT: Our app provides services like Temple Information, Cabs and Travels, Hotels, Parking, Petrol Bunks, Earning opportunities, and Customer Support. "
        "If a user asks about darshanam, crowd, or waiting time, estimate the time and tell them: 'Meanwhile, you can explore different places. Would you like me to show you nearby temples, recommend cabs, find parking spots, or locate petrol bunks from our app?' "
        "Always lightly suggest exploring our app's services when relevant without being pushy.";

    // Initialize the Gemini model with specific system instructions for Indian Temple Darshan
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
      systemInstruction: Content.system(basePrompt),
    );
    _chat = _model.startChat();

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialMessage!);
      });
    }
  }

  String _getTime() {
    final now = DateTime.now();
    int hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'pm' : 'am';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return "$hour:$minute $period";
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final timeStr = _getTime();
    setState(() {
      _messages.add({'role': 'user', 'text': text, 'time': timeStr});
      _isLoading = true;
    });

    _controller.clear();
    setState(() {
      _isTyping = false;
    });

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final botTime = _getTime();
      final responseText = response.text?.trim() ?? 'No response';

      // Pre-calculate which listings this response mentions to avoid re-rendering
      List<Map<String, dynamic>> matchedCards = [];
      if (widget.availableListings != null) {
        matchedCards = widget.availableListings!.where((e) {
          final t = e['title'] as String? ?? '';
          return t.isNotEmpty &&
              responseText.toLowerCase().contains(t.toLowerCase());
        }).toList();
      }

      setState(() {
        _messages.add({
          'role': 'bot',
          'text': responseText,
          'time': botTime,
          'cards': matchedCards,
        });
      });
    } catch (e) {
      debugPrint("Gemini API Error: $e"); // Log error for debugging
      final botTime = _getTime();
      final errorText = Provider.of<LanguageProvider>(context, listen: false).selectedLanguages.isNotEmpty
          ? TranslationService().translate('error_communicating', Provider.of<LanguageProvider>(context, listen: false).selectedLanguages.first)
          : 'Error communicating with server. Please try again.';
      setState(() {
        _messages.add({
          'role': 'bot',
          'text': '$errorText\n\nError details: $e',
          'time': botTime,
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9), // App Background Color
          image: DecorationImage(
            image: AssetImage('assets/images/om-symbol.png'),
            fit: BoxFit
                .scaleDown, // Makes it centered and unscaled instead of stretching over everything
            colorFilter: ColorFilter.mode(Colors.white70, BlendMode.lighten),
          ),
        ),
        child: Column(
          children: [
            // App-Theme Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 8,
                left: 16,
                right: 16,
              ),
              color: Colors
                  .orange, // Replaced WhatsApp Green with App Orange Theme
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/images/cropped-New-Logos-Folder.webp',
                    ), // Bot Avatar (Om logo)
                    backgroundColor: Colors.white,
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<LanguageProvider>(
                          builder: (context, provider, _) {
                            final title = provider.selectedLanguages.isNotEmpty
                                ? TranslationService().translate('darshan_assistant', provider.selectedLanguages.first)
                                : 'darshan_assistant';
                            return Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        Consumer<LanguageProvider>(
                          builder: (context, provider, _) {
                            final statusText = _isLoading
                                ? (provider.selectedLanguages.isNotEmpty
                                    ? TranslationService().translate('typing', provider.selectedLanguages.first)
                                    : 'typing')
                                : (provider.selectedLanguages.isNotEmpty
                                    ? TranslationService().translate('online', provider.selectedLanguages.first)
                                    : 'online');
                            return Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.white, size: 24),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 15,
                  bottom: 10,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 8,
                        bottom: 6,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors
                                  .orange
                                  .shade100 // App Theme Orange Bubble
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: Radius.circular(isUser ? 12 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        alignment: WrapAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 10,
                              bottom: 2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['text'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (!isUser && msg['cards'] != null)
                                  ...(msg['cards']
                                          as List<Map<String, dynamic>>)
                                      .map(
                                        (e) => Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange.shade200,
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Image.network(
                                                e['image_url'] ?? '',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, err, s) =>
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      color: Colors
                                                          .orange
                                                          .shade100,
                                                      child: const Icon(
                                                        Icons.image,
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            title: Text(
                                              e['title'] ?? '',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange.shade900,
                                              ),
                                            ),
                                            subtitle: Text(
                                              e['location'] ?? 'Location N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                msg['time'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black45,
                                ),
                              ),
                              if (isUser) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.done_all,
                                  color:
                                      Colors.orange, // Match orange theme ticks
                                  size: 16,
                                ), // Blue ticks!
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input specific to WhatsApp
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 120.0,
              ), // Padding to elevate above floating nav
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 120),
                              child: Scrollbar(
                                child: Consumer<LanguageProvider>(
                                  builder: (context, provider, _) {
                                    final hintText = provider.selectedLanguages.isNotEmpty
                                        ? TranslationService().translate('message', provider.selectedLanguages.first)
                                        : 'message';
                                    return TextField(
                                      controller: _controller,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      onChanged: (text) {
                                        setState(() {
                                          _isTyping = text.isNotEmpty;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: hintText,
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 18,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.attach_file,
                              color: Colors.grey,
                            ),
                            onPressed: () {},
                          ),
                          if (!_isTyping)
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.grey,
                              ),
                              onPressed: () {},
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      if (_isTyping) {
                        _sendMessage(_controller.text);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        color:
                            Colors.orange, // App Theme Action Button Complete
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isTyping ? Icons.send : Icons.mic,
                        color: Colors.white,
                        size: 26,
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
}
