import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample notification list (Replace with dynamic data if needed)
    final List<Map<String, String>> notifications = [
      {
        "title": "New Message",
        "subtitle": "You have received a new message from support.",
        "time": "10:00 AM"
      },
      {
        "title": "System Update",
        "subtitle": "A new update is available for the app.",
        "time": "9:30 AM"
      },
      {
        "title": "Reminder",
        "subtitle": "Don't forget your scheduled chatbot session.",
        "time": "8:00 AM"
      },
      {
        "title": "Security Alert",
        "subtitle": "Unusual login attempt detected on your account.",
        "time": "Yesterday"
      },
      {
        "title": "Welcome!",
        "subtitle": "Thank you for joining our platform.",
        "time": "2 days ago"
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.blue),
                title: Text(notification["title"]!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(notification["subtitle"]!),
                trailing: Text(notification["time"]!,
                    style: const TextStyle(color: Colors.grey)),
              ),
            );
          },
        ),
      ),
    );
  }
}