import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:flutter_application_1/screens/auth/email_singup_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/auth/find_id_screen.dart';
import 'package:flutter_application_1/screens/auth/find_password_screen.dart';

Map<String, WidgetBuilder> routes = {
  '/login': (context) => const Login(),
  '/signup': (context) => const SignUp1(),
  '/home': (context) => const MyHomePage(),
  '/findId': (context) => const FindId(),
  '/findPassword': (context) => const FindPassword()
};
