import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/models/ClosetItem.dart';
import 'package:provider/provider.dart';

// 모드 관리
class SelectionManager {
  List<ClosetItem> selectedItems = []; // 선택된 아이템

  void toggleSelection(ClosetItem item, Function(String) onError) {
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      if (_isPartAlreadySelected(item, onError)) {
        return;
      }
      selectedItems.add(item);
    }
  }

// 상하의 선택 확인
  bool _isPartAlreadySelected(ClosetItem item, Function(String) onError) {
    if (item.part == '상의' && selectedItems.any((i) => i.part == '상의')) {
      onError('이미 상의가 선택되어 있습니다');
      return true;
    } else if (item.part == '하의' && selectedItems.any((i) => i.part == '하의')) {
      onError('이미 하의가 선택되어 있습니다');
      return true;
    }
    return false;
  }

  void toggleDeletion(ClosetItem item) {
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }
  }

// 삭제 기능
  Future<void> deleteSelectedItems(
      BuildContext context, Function(String) onError) async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    LoginAuth loginAuth = Provider.of<LoginAuth>(context, listen: false);
    String? userId = loginAuth.user?.uid;

    if (userId == null) {
      onError('User is not authenticated');
      return;
    }

    for (var item in selectedItems) {
      try {
        // 스토리지 먼저 삭제 후(이미지)
        final ref = storage.refFromURL(item.imageUrl);
        await ref.delete();

        // 데이터베이스에서 정보 제거
        await firestore
            .collection('users')
            .doc(userId)
            .collection('images')
            .doc(item.id)
            .delete();
        print("Deleted Firestore document for item ${item.style}");
      } catch (e) {
        onError('Error deleting Firestore document for ${item.style}: $e');
        print('Firestore deletion error: $e');
      }
    }

    clearSelection();
  }

  // 선택 해제
  void clearSelection() {
    selectedItems.clear();
  }

// 데이터 정보 입력
  Future<String?> _showNameInputDialog(BuildContext context) async {
    String? outfitName;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Text(
            '코디 이름 입력',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          content: TextField(
            decoration: InputDecoration(
              hintText: '코디 이름을 입력해주세요',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.navy),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.navy, width: 2),
              ),
            ),
            onChanged: (value) {
              outfitName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(outfitName),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// 상하의 서버에 데이터 전달
  Future<Map<String, dynamic>> sendTopBottomToServer(
      String userId, BuildContext context) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      // Firestore에서 isProcessing 상태 확인
      final userDoc = await userRef.get();
      if (userDoc.data()?['isProcessing'] == true) {
        return {'error': '이미 처리 중인 요청이 있습니다. 잠시 후 다시 시도해주세요.'};
      }

      // FCM 토큰 가져오기
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        return {'error': '알림 토큰을 가져올 수 없습니다.'};
      }

      final hasTop = selectedItems.any((item) => item.part == '상의');
      final hasBottom = selectedItems.any((item) => item.part == '하의');

      if (!hasTop || !hasBottom) {
        return {'error': '상의와 하의를 각각 선택해주세요.'};
      }

      // 코디 이름 입력 받기
      final outfitName = await _showNameInputDialog(context);
      if (outfitName == null || outfitName.isEmpty) {
        return {'error': '코디 이름을 입력해주세요.'};
      }

      // Firestore에서 isProcessing 상태를 true로 설정
      await userRef.update({'isProcessing': true});

      final topItem = selectedItems.firstWhere((item) => item.part == '상의');
      final bottomItem = selectedItems.firstWhere((item) => item.part == '하의');

      final url = Uri.parse('http://172.18.8.232:8000/model');
      final data = {
        'userId': userId,
        'outfitName': outfitName,
        'fcmToken': fcmToken, // 서버로 전송하는 데이터에만 포함
        'top': {'id': topItem.id, 'imageUrl': topItem.imageUrl},
        'bottom': {'id': bottomItem.id, 'imageUrl': bottomItem.imageUrl},
      };

      // 서버로 데이터 전송
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': '데이터 전송 성공'};
      } else {
        await userRef.update({'isProcessing': false});
        return {'error': '데이터 전송 실패: ${response.statusCode}'};
      }
    } catch (e) {
      await userRef.update({'isProcessing': false});
      return {'error': '오류 발생: $e'};
    }
  }
}
