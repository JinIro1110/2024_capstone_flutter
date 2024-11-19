import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth/social_user_info_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

      // Firestore user check
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        // Existing user, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        // New user, navigate to user info screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SocialUserInfoScreen(user: user)),
        );
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
      // Handle the error appropriately, e.g., show a snackbar or dialog
    }
  }

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
        return snapshot.docs.first.get('email');
      } else {
        return null;
      }
    } catch (e) {
      print("Error finding user email: $e");
      return null;
    }
  }

  // phone auth credential로 수정??

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
