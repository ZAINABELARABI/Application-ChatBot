import 'package:flutter/material.dart';
import 'chat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon ChatBot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      home: const ChatScreen(), 
    );
  }
}
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _controller.clear();
      _isTyping = true;
    });

    try {
      final response = await _chatService.sendMessage(text);
      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Erreur : $e'});
      });
    }

    setState(() {
      _isTyping = false;
    });
  }

 Widget _buildMessage(Map<String, String> message) {
  final isUser = message['role'] == 'user';

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? Colors.lightGreen : Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 0),
          bottomRight: Radius.circular(isUser ? 0 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Text(
        message['content'] ?? '',
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatBot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('je suis entrain de réflichir...'),
            ),
         Padding(
  padding: const EdgeInsets.all(12),
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: _controller,
          onSubmitted: (_) => _sendMessage(),
          decoration: InputDecoration(
            hintText: 'Écris un message...',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: _sendMessage,
        child: CircleAvatar(
          backgroundColor: Colors.lightGreen,
          child: const Icon(Icons.send, color: Colors.white),
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
