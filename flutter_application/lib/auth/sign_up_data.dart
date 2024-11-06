import 'package:flutter/material.dart';

class SignUpData extends ChangeNotifier {
  String email = '';
  String password = '';
  String phone = '';
  String name = '';
  String gender = '';
  String birth = '';
  double height = 0.0;

  void setEmail(String value) {
    email = value;
    notifyListeners(); // 데이터 변경을 Provider에게 알림
  }

  void setPassword(String value) {
    password = value;
    notifyListeners(); // 데이터 변경을 Provider에게 알림
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners(); // 데이터 변경을 Provider에게 알림
  }

  void setName(String value) {
    name = value;
    notifyListeners(); // 데이터 변경을 Provider에게 알림
  }

  void setGender(String value) {
    gender = value;
    notifyListeners(); // 데이터 변경을 Provider에게 알림
  }

  void setBirth(String value) {
    birth = value;
    notifyListeners(); // 데이터 변경을 Provider에게 알림
  }

  void setHeight(double value) {
    height = value;
    notifyListeners(); // 데이터 변경을 Provider에게 알림
  }

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
