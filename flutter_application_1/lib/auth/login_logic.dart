import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginAuth with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  LoginAuth() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
  try {
    await _auth.signOut();
    _user = null; // 사용자 상태를 null로 명시적으로 설정
    notifyListeners(); // 상태 변경을 알림
  } catch (e) {
    print('Sign out error: $e');
    rethrow; // 오류를 다시 던져 MyHomePage에서 처리할 수 있도록 합니다.
  }
}

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  bool get isAuthenticated => _user != null;
}