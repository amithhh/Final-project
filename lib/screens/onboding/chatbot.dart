import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  List<Map<String, String>> chatMessages = [];
  bool _isListening = false;
  bool _isTyping = false;
  bool _isBotTyping = false;

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _isTyping = _controller.text.isNotEmpty;
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speechToText.stop();
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      chatMessages.add({'role': 'user', 'content': message});
      _controller.clear();
      _isTyping = false;
      _isBotTyping = true;
    });

    final data = {
      "model": "llama3",
      "messages": [
        {"role": "user", "content": message}
      ],
      "stream": false,
    };

    try {
      final response = await http.post(
        Uri.parse("http://localhost:11434/api/chat"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final botResponse = responseData["message"]["content"] ?? "I couldn't understand that.";

        setState(() {
          chatMessages.add({'role': 'bot', 'content': botResponse});
          _isBotTyping = false;
        });

        _speak(botResponse);
      } else {
        setState(() {
          chatMessages.add({'role': 'bot', 'content': "Error: Unable to fetch response."});
          _isBotTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        chatMessages.add({'role': 'bot', 'content': "Error: ${e.toString()}"}); 
        _isBotTyping = false;
      });
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
            const SizedBox(height: 40), // Space for status bar
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: chatMessages.length + (_isBotTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == chatMessages.length) {
                    return _typingIndicator();
                  }

                  final message = chatMessages[index];
                  final isUser = message["role"] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blueAccent : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(15),
                          topRight: const Radius.circular(15),
                          bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
                          bottomRight: isUser ? Radius.zero : const Radius.circular(15),
                        ),
                      ),
                      child: Text(
                        message["content"] ?? '',
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dotAnimation(),
              const SizedBox(width: 4),
              _dotAnimation(delay: 200),
              const SizedBox(width: 4),
              _dotAnimation(delay: 400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dotAnimation({int delay = 0}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      height: 6,
      width: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.blueAccent),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (text) => setState(() => _isTyping = text.isNotEmpty),
              onSubmitted: (text) => _sendMessage(text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _isTyping ? () => _sendMessage(_controller.text) : null,
          ),
        ],
      ),
    );
  }
}