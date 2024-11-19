// services/camera_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();
  
  // 사진 촬영 및 업로드를 처리하는 메서드
  Future<void> takeAndUploadPhoto({
    required String uid,
    required BuildContext context,
    int imageQuality = 85,
  }) async {
    try {
      // 사진 촬영
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
      );

      if (image == null) return; // 사용자가 취소한 경우

      // Firebase Storage에 업로드
      await _uploadImageToStorage(
        uid: uid,
        imageFile: File(image.path),
        context: context,
      );
    } catch (e) {
      print('Error in takeAndUploadPhoto: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라 실행 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  // Firebase Storage 업로드를 처리하는 메서드
  Future<void> _uploadImageToStorage({
    required String uid,
    required File imageFile,
    required BuildContext context,
  }) async {
    try {
      final String fileName = 'default_image.jpg';
      final String storagePath = 'users/$uid/models/$fileName';
      
      final Reference storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      await storageRef.putFile(imageFile);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 성공적으로 저장되었습니다.')),
        );
      }
    } catch (e) {
      print('Error in _uploadImageToStorage: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 저장 중 오류가 발생했습니다.')),
        );
      }
    }
  }
}