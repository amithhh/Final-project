import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const ChatbotScreen(),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isListening = false;
  bool _isTyping = false;
  bool _isBotTyping = false;
  bool _isLoadingMessages = true;

  List<Map<String, dynamic>> chatMessages = [];

  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  /// Fetch chat history from Firestore without blocking UI
  Future<void> _fetchChatHistory() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('chat_history')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(20) // ✅ Fetch only the latest 20 messages
          .get();

      setState(() {
        chatMessages = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _isLoadingMessages = false;
      });
    } catch (e) {
      print("Error fetching chat history: $e");
      setState(() => _isLoadingMessages = false);
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      chatMessages.insert(0, {'role': 'user', 'message': message});
      _controller.clear();
      _isTyping = false;
      _isBotTyping = true;
    });

    // Save user message to Firestore
    await _firestore.collection('chat_history').add({
      'userId': userId,
      'role': 'user',
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final botResponse = await fetchChatResponse(message);

    // Save bot response to Firestore
    await _firestore.collection('chat_history').add({
      'userId': userId,
      'role': 'bot',
      'message': botResponse,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      chatMessages.insert(0, {'role': 'bot', 'message': botResponse});
      _isBotTyping = false;
    });

    _speak(botResponse);
  }

  /// Fetches chatbot response with a 5-second timeout
  Future<String> fetchChatResponse(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse("http://localhost:11434/api/chat"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "model": "llama3",
              "messages": [{"role": "user", "content": message}],
              "stream": false
            }),
          )
          .timeout(const Duration(seconds: 15), onTimeout: () => throw TimeoutException("Server took too long to respond."));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData["message"]["content"] ?? "I couldn't understand that.";
      } else {
        return "Error fetching response.";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF34495E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: _isLoadingMessages
                  ? const Center(child: CircularProgressIndicator()) // ✅ Show a loader while messages load
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: chatMessages.length + (_isBotTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatMessages.length) return _typingIndicator();
                        final message = chatMessages[index];
                        final isUser = message["role"] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blueAccent : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              message["message"],
                              style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(left: 16.0, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text("Bot is typing...", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none),
              onChanged: (text) => setState(() => _isTyping = text.isNotEmpty),
              onSubmitted: (text) => _sendMessage(text),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.blueAccent), onPressed: _isTyping ? () => _sendMessage(_controller.text) : null),
        ],
      ),
    );
  }
}