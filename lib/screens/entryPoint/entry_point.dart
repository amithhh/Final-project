import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive_animation/constants.dart';
import 'package:rive_animation/screens/home/home_screen.dart';
import 'package:rive_animation/screens/onboding/chatbot.dart';
import 'package:rive_animation/utils/rive_utils.dart';
import 'package:rive_animation/screens/Menu_direction/profile.dart';
import 'package:rive_animation/screens/Menu_direction/notifications.dart';
import 'package:rive_animation/screens/Menu_direction/search.dart';
import 'package:rive_animation/screens/Menu_direction/favorites.dart';
import 'package:rive_animation/screens/Menu_direction/help.dart';
import 'package:rive_animation/screens/Menu_direction/history.dart';

import '../../model/menu.dart';
import 'components/btm_nav_item.dart';
import 'components/menu_btn.dart';
import 'components/side_bar.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint>
    with SingleTickerProviderStateMixin {
  bool isSideBarOpen = false;
  late SMIBool isMenuOpenInput;

  int _selectedIndex = 0; // Tracks selected page

  // ✅ List of pages corresponding to menu items
  final List<Widget> _pages = [
    const HomePage(),
    const ChatbotScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
    const NotificationScreen(),
    const HelpScreen(),
    const FavoritesScreen(),
    const SearchScreen(),
  ];

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });

    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
    );

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ Toggles sidebar open/close
  void _toggleSidebar() {
    isMenuOpenInput.value = !isMenuOpenInput.value;

    if (_animationController.value == 0) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    setState(() {
      isSideBarOpen = !isSideBarOpen;
    });
  }

  // ✅ Updates selected page from bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      isSideBarOpen = false; // Closes sidebar when navigating
    });

    _animationController.reverse();
  }

  // ✅ Updates selected page from sidebar menu
  void _onSidebarItemSelected(Menu menu) {
    int index = sidebarMenus.indexOf(menu);

    if (index == -1) {
      index = sidebarMenus2.indexOf(menu) + sidebarMenus.length;
    }

    // ✅ Ensure index is within bounds
    if (index >= 0 && index < _pages.length) {
      _onItemTapped(index);
    } else {
      debugPrint("Error: No matching page for index $index");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor2,
      body: Stack(
        children: [
          // ✅ Sidebar Menu (Opens when toggled)
          AnimatedPositioned(
            width: 288,
            height: MediaQuery.of(context).size.height,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 0 : -288,
            top: 0,
            child: SideBar(onItemSelected: _onSidebarItemSelected), // ✅ Pass function to SideBar
          ),

          // ✅ Main Content Area (Switches pages correctly)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(1 * animation.value - 30 * animation.value * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 265, 0),
              child: Transform.scale(
                scale: scalAnimation.value,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  child: _pages[_selectedIndex], // ✅ Load selected page dynamically
                ),
              ),
            ),
          ),

          // ✅ Menu Button
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 220 : 0,
            top: 16,
            child: MenuBtn(
              press: _toggleSidebar,
              riveOnInit: (artboard) {
                final controller = StateMachineController.fromArtboard(
                    artboard, "State Machine");

                artboard.addController(controller!);
                isMenuOpenInput = controller.findInput<bool>("isOpen") as SMIBool;
                isMenuOpenInput.value = true;
              },
            ),
          ),
        ],
      ),

      // ✅ Bottom Navigation Bar (Handles navigation correctly)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: backgroundColor2.withOpacity(0.8),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: backgroundColor2.withOpacity(0.3),
                offset: const Offset(0, 20),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              bottomNavItems.length,
              (index) {
                Menu navBar = bottomNavItems[index];
                return BtmNavItem(
                  navBar: navBar,
                  press: () {
                    RiveUtils.chnageSMIBoolState(navBar.rive.status!);
                    _onItemTapped(index); // ✅ Update selected page
                  },
                  riveOnInit: (artboard) {
                    navBar.rive.status = RiveUtils.getRiveInput(
                      artboard, stateMachineName: navBar.rive.stateMachineName,
                    );
                  },
                  selectedNav: bottomNavItems[_selectedIndex], // ✅ Track selection
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}