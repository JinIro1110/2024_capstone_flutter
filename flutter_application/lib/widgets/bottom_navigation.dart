import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';

// 앱 하단의 네비게이션 바 위젯
class BottomNavigation extends StatelessWidget {
  final int selectedIndex; // 현재 선택된 탭의 인덱스
  final Function(int) onItemTapped; // 탭 선택 시 실행할 콜백 함수

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
          icon: Icon(Icons.drafts, size: 25), // 첫 번째 탭: "내 모델"
          label: '내 모델',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 25), // 두 번째 탭: "홈"
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shop, size: 25), // 세 번째 탭: "쇼핑몰"
          label: '쇼핑몰',
        ),
      ],
      currentIndex: selectedIndex, // 현재 선택된 탭의 인덱스
      selectedItemColor: AppColors.white, // 선택된 아이템 색상
      unselectedItemColor: AppColors.navy, // 선택되지 않은 아이템 색상
      backgroundColor: AppColors.blue, // 네비게이션 바 배경 색상
      type: BottomNavigationBarType.fixed, // 탭의 고정 레이아웃 설정
      onTap: onItemTapped, // 탭 클릭 시 콜백 함수 호출
    );
  }
}
