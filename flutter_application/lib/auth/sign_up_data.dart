import 'package:flutter/material.dart';

/// 회원가입 시 입력 데이터를 관리하는 클래스
/// 입력값 변경 시 상태를 알리기 위해 ChangeNotifier를 상속
class SignUpData extends ChangeNotifier {
  String email = ''; // 이메일
  String password = ''; // 비밀번호
  String phone = ''; // 전화번호
  String name = ''; // 이름
  String gender = ''; // 성별
  String birth = ''; // 생년월일
  double height = 0.0; // 키

  /// 이메일 값을 설정하고 변경 사항을 알림
  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  /// 비밀번호 값을 설정하고 변경 사항을 알림
  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  /// 전화번호 값을 설정하고 변경 사항을 알림
  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  /// 이름 값을 설정하고 변경 사항을 알림
  void setName(String value) {
    name = value;
    notifyListeners();
  }

  /// 성별 값을 설정하고 변경 사항을 알림
  void setGender(String value) {
    gender = value;
    notifyListeners();
  }

  /// 생년월일 값을 설정하고 변경 사항을 알림
  void setBirth(String value) {
    birth = value;
    notifyListeners();
  }

  /// 키 값을 설정하고 변경 사항을 알림
  void setHeight(double value) {
    height = value;
    notifyListeners();
  }

  /// 모든 데이터를 초기화하고 변경 사항을 알림
  void clearData() {
    email = '';
    password = '';
    phone = '';
    name = '';
    gender = '';
    birth = '';
    height = 0.0;
    notifyListeners();
  }
}
