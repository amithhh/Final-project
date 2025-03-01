import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> chatMessages = [
    {"role": "system", "content": "You are a helpful assistant."},
  ];

  Future<void> query(String prompt) async {
    final message = {
      "role": "user",
      "content": prompt,
    };

    // Add user message to chatMessages
    chatMessages.add(message);

    final data = {
      "model": "llama3.2",  // Specify your model version here (if needed)
      "messages": chatMessages,
      "stream": false,  // Set stream to true or false based on your API configuration
    };

    try {
      // Send a POST request to the Llama API
      final response = await http.post(
        Uri.parse("http://localhost:11434/api/chat"),  // Replace with the correct Llama API URL
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // If the API response is successful, parse the response
        final responseData = json.decode(response.body);
        final botResponse = responseData["message"]["content"];  // Assuming the response contains a field "message" with "content"

        // Add the bot's response to the chatMessages list
        chatMessages.add(
          {"role": "system", "content": botResponse},
        );
      } else {
        // Handle error if the response status is not OK
        chatMessages.add(
          {
            "role": "system",
            "content": "Error: Unable to fetch response from the server.",
          },
        );
      }
    } catch (e) {
      // Handle any exceptions that occur during the API call
      chatMessages.add(
        {
          "role": "system",
          "content": "Error: ${e.toString()}",
        },
      );
    }

    // Clear the text input and update the UI with the new message
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage with Chatbot"),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Chatbot",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(),
              // Chatbot UI
              Container(
                padding: const EdgeInsets.all(16),
                height: 500, // Adjust as necessary
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: chatMessages.length,
                        itemBuilder: (context, index) {
                          if (index == 0) return const SizedBox.shrink();
                          final message = chatMessages[index];
                          return Align(
                            alignment: message["role"] == 'system'
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: message["role"] == 'system'
                                    ? Colors.grey[300]
                                    : Colors.blue[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(message["content"] ?? ''),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Enter your prompt",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              query(_controller.text);
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.blue),
                        ),
                      ),
                    ),
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