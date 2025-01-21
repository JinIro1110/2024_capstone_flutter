import 'package:flutter/material.dart';

class AppColors {
  // 앱에서 사용할 색상 정의

  static const Color white = Color.fromARGB(255, 244, 238, 255); // 흰색 (RGB: 244, 238, 255)
  static const Color lavender = Color.fromARGB(255, 220, 214, 247); // 라벤더 색상 (RGB: 220, 214, 247)
  static const Color blue = Color.fromARGB(255, 166, 177, 225);    // 블루 색상 (RGB: 166, 177, 225)
  static const Color navy = Color.fromARGB(255, 66, 72, 116);      // 네이비 색상 (RGB: 66, 72, 116)
}

class ClosetConstants {
  // 앱의 레이아웃 및 UI 관련 상수 설정

  static const int pageSize = 10;  // 페이지네이션에 표시될 아이템 수
  static const double gridPadding = 8.0;  // 그리드 간 여백 패딩 값
  static const int gridCrossAxisCount = 2;  // 그리드 열 개수
  static const double gridCrossSpacing = 10.0;  // 그리드 간 가로 간격
  static const double gridMainSpacing = 10.0;  // 그리드 세로 간격
  static const double gridChildAspectRatio = 0.75;  // 그리드 아이템의 비율 (너비/높이 비율)
}
