import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Need Help?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Follow these steps to navigate through the app:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildStepTile("1. Open the Home Page and select an option."),
            _buildStepTile("2. Click 'Chat' to interact with the chatbot."),
            _buildStepTile("3. Use 'Search' to find what you need."),
            _buildStepTile("4. Access 'Profile' to manage your settings."),
            _buildStepTile("5. If you have issues, check FAQs below or contact support."),
            const SizedBox(height: 20),
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildFAQTile("How do I reset my password?", "Go to Profile > Settings > Reset Password."),
            _buildFAQTile("Why is my chatbot not responding?", "Ensure you have an internet connection and try again."),
            _buildFAQTile("How do I contact support?", "Scroll down and click the 'Contact Support' button."),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showContactDialog(context);
                },
                icon: const Icon(Icons.support_agent),
                label: const Text("Contact Support"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTile(String text) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [Padding(padding: const EdgeInsets.all(8.0), child: Text(answer))],
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Contact Support"),
          content: const Text("Email: support@example.com\nPhone: +123 456 7890"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
          ],
        );
      },
    );
  }
}