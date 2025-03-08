import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive_animation/screens/entryPoint/entry_point.dart';

class SignInForm extends StatefulWidget {
  final Function onSignInSuccess;

  const SignInForm({super.key, required this.onSignInSuccess});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isShowLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signIn(BuildContext context) async {
    setState(() {
      isShowLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        // ✅ Trim email & password before sending to Firebase
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          await saveUserLoginData(user); // ✅ Save login info in Firestore
        }

        setState(() {
          isShowLoading = false;
        });

        widget.onSignInSuccess(); // ✅ Notify parent widget

        // ✅ Navigate to Entry Point (Home)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EntryPoint()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          isShowLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "An error occurred")),
        );
      }
    } else {
      setState(() {
        isShowLoading = false;
      });
    }
  }

  // ✅ Improved Firestore Save with Error Handling
  Future<void> saveUserLoginData(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // ✅ Prevents overwriting existing data
    } catch (e) {
      debugPrint("Error saving user data: $e"); // ✅ Logs Firestore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Email", style: TextStyle(color: Colors.black54)),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: TextFormField(
              controller: _emailController,
              validator: (value) =>
                  value!.trim().isEmpty ? "Please enter your email." : null,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SvgPicture.asset("assets/icons/email.svg"),
                ),
              ),
            ),
          ),
          const Text("Password", style: TextStyle(color: Colors.black54)),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              validator: (value) =>
                  value!.trim().isEmpty ? "Please enter your password." : null,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SvgPicture.asset("assets/icons/password.svg"),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: ElevatedButton.icon(
              onPressed: () {
                signIn(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF77D8E),
                minimumSize: const Size(double.infinity, 56),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
              ),
              icon: const Icon(
                CupertinoIcons.arrow_right,
                color: Color(0xFFFE0037),
              ),
              label: const Text("Sign In"),
            ),
          ),
          if (isShowLoading)
            const Center(child: CircularProgressIndicator()), // ✅ Loading spinner
        ],
      ),
    );
  }
}