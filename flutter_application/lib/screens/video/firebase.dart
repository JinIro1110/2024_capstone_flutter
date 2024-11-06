import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:provider/provider.dart';

class FirebaseService {
  FirebaseStorage? storage;

  FirebaseService() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    storage = FirebaseStorage.instance;
  }

  Future<void> uploadVideosToFirebase(List<File> recordedVideoFiles, BuildContext context) async {
    if (storage == null) return;

    final user = Provider.of<LoginAuth>(context, listen: false).user;
    if (user == null) {
      print('사용자가 로그인되어 있지 않습니다.');
      return;
    }

    try {
      final storageRef = storage!.ref().child('videos/${user.uid}'); // 사용자별 폴더

      // 고정된 이름으로 저장하기
      List<String> videoNames = ['앞.mp4', '오른.mp4', '왼.mp4', '뒤.mp4'];

      // 비디오 파일 목록을 순차적으로 업로드
      for (int i = 0; i < recordedVideoFiles.length; i++) {
        String fileName = videoNames[i % videoNames.length];  // 고정된 이름 순서대로 사용
        Reference ref = storageRef.child(fileName);  // 고정된 이름으로 저장
        SettableMetadata metadata = SettableMetadata(contentType: 'video/mp4');

        UploadTask uploadTask = ref.putFile(recordedVideoFiles[i], metadata);

        try {
          await uploadTask.whenComplete(() => print('Video uploaded to Firebase Storage'));
          String downloadUrl = await ref.getDownloadURL();
          print('Download URL: $downloadUrl');
        } catch (e) {
          print('Error uploading video or getting download URL: $e');
        }
      }
    } catch (e) {
      print('Error uploading videos to Firebase: $e');
    }
  }
}
