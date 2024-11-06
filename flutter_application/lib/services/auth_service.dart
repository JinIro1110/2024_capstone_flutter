import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<String?> findUserEmail(String name, String phone, String birth) async {
    try {
      // Firebase Firestore에서 사용자 정보 조회
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: name)
          .where('phone', isEqualTo: phone)
          .where('birth', isEqualTo: birth)
          .get();

      // 사용자 정보가 존재할 경우 이메일 반환
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.get('email');
      } else {
        // 사용자 정보가 없을 경우 null 반환
        return null;
      }
    } catch (e) {
      // 오류 발생 시 null 반환
      return null;
    }
  }

  // phone auth credential로 수정??

  Future<bool> findUserPassword(String email, String name, String birth) async {
    try {
      // Firestore에서 사용자 정보 조회
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('name', isEqualTo: name)
          .where('birth', isEqualTo: birth)
          .get();

      // Check the results of the query
      print('Query snapshot length: ${snapshot.docs.length}'); // Debug log

      if (snapshot.docs.isNotEmpty) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        return true;
      } else {
        print('User not found');
        return false;
      }
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }
}
