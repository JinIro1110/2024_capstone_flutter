import 'package:flutter/material.dart';

// 스낵바를 보여주는 서비스 클래스
class SnackbarService {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>(); // ScaffoldMessengerState 키

  // 스낵바 표시 메서드
  void showSnackbar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)), // 스낵바에 메시지 표시
    );
  }
}
