import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive_animation/screens/onboding/onboding_screen.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              user?.displayName ?? "No Name Available",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              user?.email ?? "No Email Available",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.verified_user, color: Colors.blue),
              title: Text(user?.uid ?? "No User ID"),
              subtitle: const Text("User ID"),
            ),
            ListTile(
              leading: Icon(
                user?.emailVerified == true ? Icons.check_circle : Icons.error,
                color: user?.emailVerified == true ? Colors.green : Colors.red,
              ),
              title: Text(user?.emailVerified == true
                  ? "Email Verified"
                  : "Email Not Verified"),
            ),
            const Spacer(),
ElevatedButton.icon(
  onPressed: () async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OnbodingScreen(), // ✅ Navigate to Onboarding
      ),
    );
  },
  icon: const Icon(Icons.logout),
  label: const Text("Sign Out"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  ),
),
          ],
        ),
      ),
    );
  }
}