import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth/social_user_info_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 인스턴스

  // Google 소셜 로그인
  Future<void> googleSocialLogin(BuildContext context) async {
    try {
      // Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = 
          await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Sign-In
      final userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw Exception("Failed to retrieve user info.");
      }

      // Firestore 사용자 확인
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // 기존 사용자
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        // 신규 사용자
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SocialUserInfoScreen(user: user)),
        );
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
    }
  }

  // 사용자 이메일 찾기
  Future<String?> findUserEmail(String name, String phone, String birth) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: name)
          .where('phone', isEqualTo: phone)
          .where('birth', isEqualTo: birth)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.get('email'); // 이메일 반환
      } else {
        return null; // 사용자 없음
      }
    } catch (e) {
      print("Error finding user email: $e");
      return null; // 에러 발생
    }
  }

  // 비밀번호 찾기
  Future<bool> findUserPassword(String email, String name, String birth) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('name', isEqualTo: name)
          .where('birth', isEqualTo: birth)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email); // 비밀번호 재설정 이메일 전송
        return true;
      } else {
        print('User not found'); // 사용자 없음
        return false;
      }
    } catch (e) {
      print('Error sending password reset email: $e'); // 에러 발생
      return false;
    }
  }
}
