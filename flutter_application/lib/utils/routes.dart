import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:flutter_application_1/screens/auth/email_singup_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/auth/find_id_screen.dart';
import 'package:flutter_application_1/screens/auth/find_password_screen.dart';

/// 앱 내 라우팅 설정
Map<String, WidgetBuilder> routes = {
  '/login': (context) => const Login(),  // 로그인 화면으로 이동
  '/signup': (context) => const SignUp1(),  // 회원가입 화면으로 이동
  '/home': (context) => const MyHomePage(),  // 메인 화면으로 이동
  '/findId': (context) => const FindId(),  // 아이디 찾기 화면으로 이동
  '/findPassword': (context) => const FindPassword()  // 비밀번호 찾기 화면으로 이동
};
