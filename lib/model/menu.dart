import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'rive_model.dart';
import 'package:rive_animation/screens/onboding/chatbot.dart';
import 'package:rive_animation/screens/Menu_direction/profile.dart';
import 'package:rive_animation/screens/Menu_direction/notifications.dart';
import 'package:rive_animation/screens/Menu_direction/search.dart';
import 'package:rive_animation/screens/home/home_screen.dart';
import 'package:rive_animation/screens/Menu_direction/favorites.dart';
import 'package:rive_animation/screens/Menu_direction/help.dart';
import 'package:rive_animation/screens/Menu_direction/history.dart';

// Define a Menu model with navigation capability
class Menu {
  final String title;
  final RiveModel rive;
  final Widget page; // Page to navigate to

  Menu({required this.title, required this.rive, required this.page});
}

// Sidebar Menus (Primary)
List<Menu> sidebarMenus = [
  Menu(
    title: "Home",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "HOME",
        stateMachineName: "HOME_interactivity"),
    page: const HomePage(),
  ),
  Menu(
    title: "Search",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "SEARCH",
        stateMachineName: "SEARCH_Interactivity"),
    page: const SearchScreen(),
  ),
  Menu(
    title: "Help",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "CHAT",
        stateMachineName: "CHAT_Interactivity"),
    page: const HelpScreen(),
  ),
];

// Sidebar Menus (Secondary)
List<Menu> sidebarMenus2 = [
  Menu(
    title: "History",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "TIMER",
        stateMachineName: "TIMER_Interactivity"),
    page: const HistoryScreen(),
  ),
  Menu(
    title: "Notifications",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "BELL",
        stateMachineName: "BELL_Interactivity"),
    page: const NotificationScreen(),
  ),
];

// Bottom Navigation Items
List<Menu> bottomNavItems = [
  Menu(
    title: "Chat",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "CHAT",
        stateMachineName: "CHAT_Interactivity"),
    page: const ChatbotScreen(),
  ),
  Menu(
    title: "Search",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "SEARCH",
        stateMachineName: "SEARCH_Interactivity"),
    page: const SearchScreen(),
  ),
  Menu(
    title: "Timer",  
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "TIMER",
        stateMachineName: "TIMER_Interactivity"),
    page: const HistoryScreen(),
  ),
  Menu(
    title: "Notification",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "BELL",
        stateMachineName: "BELL_Interactivity"),
    page: const NotificationScreen(),
  ),
  Menu(
    title: "Profile",
    rive: RiveModel(
        src: "assets/RiveAssets/icons.riv",
        artboard: "USER",
        stateMachineName: "USER_Interactivity"),
    page: const ProfileScreen(),
  ),
];

// Function to create Sidebar Menu Items
Widget buildSidebarMenu(BuildContext context, List<Menu> menuList) {
  return Column(
    children: menuList.map((menu) {
      return ListTile(
        leading: SizedBox(
          height: 40,
          width: 40,
          child: RiveAnimation.asset(
            menu.rive.src,
            artboard: menu.rive.artboard,
            stateMachines: [menu.rive.stateMachineName],
          ),
        ),
        title: Text(menu.title),
        onTap: () {
          Navigator.push( // ✅ Fix: Prevents animation-only issue
            context,
            MaterialPageRoute(builder: (context) => menu.page),
          );
        },
      );
    }).toList(),
  );
}

// Function to create Bottom Navigation Bar
Widget buildBottomNavBar(BuildContext context, ValueNotifier<int> selectedIndex) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: selectedIndex.value,  // ✅ Tracks active tab
    onTap: (index) {
      selectedIndex.value = index;  // ✅ Updates selected tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => bottomNavItems[index].page),
      );
    },
    items: bottomNavItems.map((menu) {
      return BottomNavigationBarItem(
        icon: SizedBox(
          height: 50,
          width: 50,
          child: RiveAnimation.asset(
            menu.rive.src,
            artboard: menu.rive.artboard,
            stateMachines: [menu.rive.stateMachineName],
            fit: BoxFit.contain,
          ),
        ),
        label: menu.title,
      );
    }).toList(),
  );
}
