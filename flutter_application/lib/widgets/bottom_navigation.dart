import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.drafts, size: 30),
          label: '내 모델',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shop, size: 30),
          label: '쇼핑몰',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: AppColors.white,
      unselectedItemColor: AppColors.navy,
      backgroundColor: AppColors.blue,
      type: BottomNavigationBarType.fixed,
      onTap: onItemTapped,
    );
  }
}

