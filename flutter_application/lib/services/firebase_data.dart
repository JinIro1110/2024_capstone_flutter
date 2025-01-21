import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/Metadata.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker(); // 이미지 선택기
  final FirebaseStorage storage = FirebaseStorage.instance; // Firebase Storage 인스턴스

  // 카메라로 사진 촬영 및 업로드
  Future<Map<String, dynamic>> uploadImageFromCamera({
    required String userId,
    required BuildContext context,
    required Function(ClothingMetadata, String) onUploadSuccess, // 업로드 성공 콜백
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera); // 카메라로 사진 촬영
      if (photo == null) {
        return {'error': 'No image selected'}; // 사진 미선택
      }

      // 메타데이터 입력 다이얼로그 표시
      final metadata = await showDialog<ClothingMetadata>(
        context: context,
        builder: (context) => const MetadataInputDialog(),
      );

      if (metadata == null) {
        return {'error': 'No metadata provided'}; // 메타데이터 미입력
      }

      // 이미지 Firebase Storage에 업로드
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref('users/$userId/images/$fileName'); // 저장 경로 설정
      await ref.putFile(File(photo.path)); // 파일 업로드
      final downloadUrl = await ref.getDownloadURL(); // 다운로드 URL 가져오기

      onUploadSuccess(metadata, downloadUrl); // 업로드 성공 콜백 호출
      return {'success': true, 'url': downloadUrl}; // 성공 결과 반환
    } catch (e) {
      print('Error uploading image: $e'); // 에러 로그 출력
      return {'error': 'Failed to upload image'}; // 실패 결과 반환
    }
  }
}
