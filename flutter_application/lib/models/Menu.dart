import 'package:flutter/material.dart';

class MenuOption {
  final Icon icon;
  final String title;
  final VoidCallback onTap;

  MenuOption({required this.icon, required this.title, required this.onTap});
}

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Color lightPurple;
  final Color darkGrey;
  final Color lightGrey;

  const BottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.lightPurple,
    required this.darkGrey,
    required this.lightGrey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.videocam),
          label: 'Record',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Middle',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.create),
          label: 'Create Model',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shop),
          label: 'Mall',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: lightPurple,
      unselectedItemColor: darkGrey,
      backgroundColor: lightGrey,
      type: BottomNavigationBarType.fixed,
      onTap: onItemTapped,
    );
  }
}

