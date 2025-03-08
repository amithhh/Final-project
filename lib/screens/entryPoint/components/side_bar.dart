import 'package:flutter/material.dart';
import '../../../model/menu.dart';
import '../../../utils/rive_utils.dart';
import 'info_card.dart';
import 'side_menu.dart';

class SideBar extends StatefulWidget {
  final Function(Menu) onItemSelected; // Callback for menu selection

  const SideBar({super.key, required this.onItemSelected});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Menu selectedSideMenu = sidebarMenus.first;

  void _handleMenuTap(Menu menu) {
    RiveUtils.chnageSMIBoolState(menu.rive.status!);
    
    setState(() {
      selectedSideMenu = menu;
    });

    widget.onItemSelected(menu); // Update selected screen
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF17203A),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InfoCard(name: "", bio: ""),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "Browse".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              ...sidebarMenus.map((menu) => SideMenu(
                    menu: menu,
                    selectedMenu: selectedSideMenu,
                    press: () => _handleMenuTap(menu),
                    riveOnInit: (artboard) {
                      menu.rive.status = RiveUtils.getRiveInput(
                        artboard,
                        stateMachineName: menu.rive.stateMachineName,
                      );
                    },
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 40, bottom: 16),
                child: Text(
                  "History".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              ...sidebarMenus2.map((menu) => SideMenu(
                    menu: menu,
                    selectedMenu: selectedSideMenu,
                    press: () => _handleMenuTap(menu),
                    riveOnInit: (artboard) {
                      menu.rive.status = RiveUtils.getRiveInput(
                        artboard,
                        stateMachineName: menu.rive.stateMachineName,
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}