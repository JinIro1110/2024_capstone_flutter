import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// FirebaseAuth를 사용하여 로그인, 회원가입, 로그아웃 등의 인증 기능을 제공
class LoginAuth with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 인스턴스
  User? _user; // 현재 로그인된 사용자 정보

  /// 생성자: 인증 상태 변경을 감지하여 사용자 정보를 업데이트하고 상태 변경 알림
  LoginAuth() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  /// 현재 로그인된 사용자 정보 반환
  User? get user => _user;

  /// 이메일과 비밀번호로 로그인
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('로그인 실패: $e');
      rethrow; // 예외를 다시 상위로 던짐
    }
  }

  /// 사용자 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null; // 사용자 정보 초기화
      notifyListeners(); // 상태 변경 알림
    } catch (e) {
      print('로그아웃 실패: $e');
      rethrow;
    }
  }

  /// 이메일과 비밀번호로 회원가입
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('회원가입 실패: $e');
      rethrow;
    }
  }

  /// 사용자가 로그인 상태인지 확인
  bool get isAuthenticated => _user != null;
}
