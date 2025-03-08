import 'package:flutter/material.dart';
import 'package:rive_animation/screens/Menu_direction/profile.dart';
import 'package:rive_animation/screens/onboding/chatbot.dart'; 
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLargeButton(
              context,
              "assets/images/chatbot.png", // Add your chatbot image here
              "Open Chatbot",
              const ChatbotScreen(),
            ),
            const SizedBox(height: 20),
            _buildLargeButton(
              context,
              "assets/images/settings.png", // Add your settings image here
              "Open Settings",
              const SettingsPage(),
            ),
            const SizedBox(height: 20),
            _buildLargeButton(
              context,
              "assets/icons/profile_img.png", // Add your profile image here
              "Open Profile",
              const ProfileScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeButton(BuildContext context, String imagePath, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Container(
        height: 120, // Adjust button size
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(imagePath, width: 80, height: 80), // Image size
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages for navigation

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: const Center(child: Text("Settings Page")),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: const Center(child: Text("Profile Page")),
    );
  }
}