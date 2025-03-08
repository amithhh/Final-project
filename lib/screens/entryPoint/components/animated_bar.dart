import 'package:flutter/material.dart';

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({
    super.key,
    required this.isActive,
    required this.onTap, // Function to handle navigation on tap
  });

  final bool isActive;
  final VoidCallback onTap; // Function that triggers navigation

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Detects user tap and triggers navigation
      child: AnimatedContainer(
        margin: const EdgeInsets.only(bottom: 2),
        duration: const Duration(milliseconds: 200),
        height: 4,
        width: isActive ? 20 : 0,
        decoration: const BoxDecoration(
          color: Color(0xFF81B4FF),
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),
    );
  }
}