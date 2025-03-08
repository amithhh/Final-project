import 'package:flutter/material.dart';
import 'sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SignUpForm(
          onSignUpSuccess: () {
            // After successful sign-up, go to the chatbot screen or login screen
            Navigator.of(context).pushReplacementNamed('/chatbot');
          },
        ),
      ),
    );
  }
}