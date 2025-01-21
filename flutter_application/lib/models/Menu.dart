import 'package:flutter/material.dart';

// 메뉴 옵션을 나타내는 데이터 클래스
class MenuOption {
  final Icon icon; // 메뉴 항목에 표시될 아이콘
  final String title; // 메뉴 항목의 제목
  final VoidCallback onTap; // 메뉴 항목을 클릭했을 때 실행될 콜백 함수

  // 생성자를 통해 메뉴 항목의 필드를 초기화
  MenuOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
