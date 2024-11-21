import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/models/ClosetItem.dart';
import 'package:provider/provider.dart';

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
        print(item.id);
        print(userId);
        // First, delete the image from Firebase Storage
        final ref = storage.refFromURL(item.imageUrl);
        await ref.delete();

        // Now, delete the Firestore document
        await firestore
            .collection('closet')
            .doc(userId)
            .collection('images')
            .doc(item.id)
            .delete();
        print("Deleted Firestore document for item ${item.style}");
      } catch (e) {
        // Log specific error when deleting Firestore document
        onError('Error deleting Firestore document for ${item.style}: $e');
        print('Firestore deletion error: $e');
      }
    }

    clearSelection();
  }

  // Clear all selected items
  void clearSelection() {
    selectedItems.clear();
  }

  Future<String?> _showNameInputDialog(BuildContext context) async {
    String? outfitName;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('코디 이름 입력'),
          content: TextField(
            decoration: InputDecoration(
              hintText: '코디 이름을 입력해주세요',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              outfitName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(outfitName);
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> sendTopBottomToServer(
      String userId, BuildContext context) async {
    // 상의와 하의 선택 확인
    final hasTop = selectedItems.any((item) => item.part == '상의');
    final hasBottom = selectedItems.any((item) => item.part == '하의');

    if (!hasTop || !hasBottom) {
      return {'error': '상의와 하의를 각각 선택해주세요.'};
    }

    // 이름 입력 다이얼로그 표시
    final outfitName = await _showNameInputDialog(context);

    // 사용자가 취소했거나 이름을 입력하지 않은 경우
    if (outfitName == null || outfitName.isEmpty) {
      return {'error': '코디 이름을 입력해주세요.'};
    }

    final topItem = selectedItems.firstWhere((item) => item.part == '상의');
    final bottomItem = selectedItems.firstWhere((item) => item.part == '하의');

    final url = Uri.parse('http://172.30.5.229:3000/model');
    final data = {
      'userId': userId,
      'outfitName': outfitName, // 새로 추가된 이름 필드
      'top': {
        'imageUrl': topItem.imageUrl,
      },
      'bottom': {
        'imageUrl': bottomItem.imageUrl,
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': '데이터 전송 성공'};
      } else {
        return {'error': '데이터 전송 실패: ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': '오류 발생: $e'};
    }
  }
}
