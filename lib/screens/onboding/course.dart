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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
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
  final List<Map<String, String>> chatMessages = [];
  bool _isListening = false;
  bool _isTyping = false;

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage('en-US'); // Malayalam
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(1.1);
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
    });

    final data = {
      "model": "llama3.2",
      "messages": chatMessages,
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
        final botResponse =
            responseData["message"]["content"] ?? "I couldn't understand that.";
        setState(() => chatMessages.add({'role': 'system', 'content': botResponse}));
        _speak(botResponse);
      } else {
        setState(() => chatMessages.add({'role': 'system', 'content': "Error fetching response."}));
      }
    } catch (e) {
      setState(() => chatMessages.add({'role': 'system', 'content': "Error: ${e.toString()}"}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatbot", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 212, 122, 164),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                final isUser = message["role"] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF25D366) : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message["content"] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      onChanged: (text) {
                        setState(() {
                          _isTyping = text.isNotEmpty;
                        });
                      },
                      onSubmitted: (text) => _sendMessage(text), // 🔹 ENTER KEY sends message
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isTyping ? () => _sendMessage(_controller.text) : (_isListening ? _stopListening : _startListening),
                  child: CircleAvatar(
                    backgroundColor: _isTyping ? const Color.fromARGB(255, 212, 122, 164) : const Color.fromARGB(255, 212, 122, 164),
                    radius: 25,
                    child: Icon(
                      _isTyping ? Icons.send : (_isListening ? Icons.mic_off : Icons.mic),
                      color: Colors.white,
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