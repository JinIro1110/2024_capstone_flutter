// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_application_1/models/MallItem.dart';

// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<List<MallItem>> loadItems(int limit, DocumentSnapshot? lastDocument) async {
//     Query query = _firestore.collection('items').orderBy('Code', descending: true).limit(limit);

//     if (lastDocument != null) {
//       query = query.startAfterDocument(lastDocument);
//     }

//     final snapshot = await query.get();

//     return Future.wait(snapshot.docs.map((doc) async {
//       final data = doc.data() as Map<String, dynamic>;
//       final storageRef = FirebaseStorage.instance.ref().child('items/${doc.id}.jpg');
//       final imageUrl = await storageRef.getDownloadURL();

//       return MallItem(
//         code: data['Code']?.toString() ?? '',
//         name: data['Name'] ?? '',
//         price: data['Price']?.toString() ?? '',
//         brand: data['Brand'] ?? '',
//         category: '${data['Category']?['Main'] ?? ''} > ${data['Category']?['Sub'] ?? ''}',
//         mainCategory: data['Category']?['Main'] ?? '',
//         subCategory: data['Category']?['Sub'] ?? '',
//         imageUrl: imageUrl,
//         link: data['Link'] ?? '',
//       );
//     }));
//   }
// }

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/Metadata.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage storage = FirebaseStorage.instance;
  
  Future<Map<String, dynamic>> uploadImageFromCamera({
    required String userId,
    required BuildContext context,
    required Function(ClothingMetadata, String) onUploadSuccess,
  }) async {
    try {
      // 카메라로 사진 촬영
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) {
        return {'error': 'No image selected'};
      }

      // 메타데이터 입력 다이얼로그 표시
      final metadata = await showDialog<ClothingMetadata>(
        context: context,
        builder: (context) => const MetadataInputDialog(),
      );

      if (metadata == null) {
        return {'error': 'No metadata provided'};
      }

      // 이미지 업로드
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref('users/$userId/images/$fileName');

      await ref.putFile(File(photo.path));
      final downloadUrl = await ref.getDownloadURL();

      // 성공 콜백 호출
      onUploadSuccess(metadata, downloadUrl);
      
      return {'success': true, 'url': downloadUrl};
    } catch (e) {
      print('Error uploading image: $e');
      return {'error': 'Failed to upload image'};
    }
  }
}