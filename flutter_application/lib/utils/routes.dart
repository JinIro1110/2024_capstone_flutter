import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth_screen/login/login.dart';
import 'package:flutter_application_1/screens/auth_screen/sign_up/sign_up_1.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/auth_screen/find/find_id.dart';
import 'package:flutter_application_1/screens/auth_screen/find/find_password.dart';

Map<String, WidgetBuilder> routes = {
  '/login': (context) => const Login(),
  '/signup': (context) => const SignUp1(),
  '/home': (context) => const MyHomePage(),
  '/findId': (context) => const FindId(),
  '/findPassword': (context) => const FindPassword()
};
