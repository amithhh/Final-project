import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../../model/menu.dart';
import 'animated_bar.dart';

class BtmNavItem extends StatelessWidget {
  const BtmNavItem({
    super.key,
    required this.navBar,
    required this.press, // ✅ Function to handle navigation
    required this.riveOnInit,
    required this.selectedNav,
  });

  final Menu navBar;
  final VoidCallback press; // ✅ Navigation function
  final ValueChanged<Artboard> riveOnInit;
  final Menu selectedNav;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        press(); // ✅ Calls navigation function when tapped
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBar(
            isActive: selectedNav == navBar,
            onTap: press, // ✅ Ensure the bar animation follows the active page
          ),
          SizedBox(
            height: 36,
            width: 36,
            child: Opacity(
              opacity: selectedNav == navBar ? 1 : 0.5, // ✅ Highlight active icon
              child: RiveAnimation.asset(
                navBar.rive.src,
                artboard: navBar.rive.artboard,
                onInit: riveOnInit, // ✅ Initialize animation
              ),
            ),
          ),
        ],
      ),
    );
  }
}