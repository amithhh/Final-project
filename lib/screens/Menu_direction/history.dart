import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String? userId = auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("User & Chat History")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("User Login History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('users').orderBy('lastLogin', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final users = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final data = users[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(Icons.account_circle, color: Colors.blue),
                        title: Text(data['email'] ?? 'Unknown User'),
                        subtitle: Text("Last login: ${data['lastLogin'].toDate()}"),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("Chatbot Conversation History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('chat_history').where('userId', isEqualTo: userId).orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final chats = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final data = chats[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: Icon(data['role'] == 'user' ? Icons.person : Icons.smart_toy, color: Colors.blue),
                        title: Text(data['message']),
                        subtitle: Text("At: ${data['timestamp'].toDate()}"),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}