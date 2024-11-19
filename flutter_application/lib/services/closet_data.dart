import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ClosetItem.dart';

class ClosetDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int pageSize = 10;

  // 초기 데이터 로드
  Future<Map<String, dynamic>> loadInitialClosetData(String userId) async {
    try {
      final collectionPath = 'users/$userId/images';
      
      final snapshot = await _firestore
          .collection(collectionPath)
          .orderBy('timestamp', descending: true)
          .limit(pageSize)
          .get();

      final items = snapshot.docs
          .map((doc) => ClosetItem.fromFirestore(doc))
          .toList();

      return {
        'items': items,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        'error': null,
      };
    } catch (e) {
      return {
        'items': <ClosetItem>[],
        'lastDocument': null,
        'error': 'Failed to load closet items: $e',
      };
    }
  }

  // 추가 데이터 로드 (페이지네이션)
  Future<Map<String, dynamic>> loadMoreClosetData(
    String userId,
    DocumentSnapshot lastDocument,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users/$userId/images')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument)
          .limit(pageSize)
          .get();

      final newItems = snapshot.docs
          .map((doc) => ClosetItem.fromFirestore(doc))
          .toList();

      return {
        'items': newItems,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        'error': null,
      };
    } catch (e) {
      return {
        'items': <ClosetItem>[],
        'lastDocument': null,
        'error': 'Failed to load more items: $e',
      };
    }
  }

  // 새 아이템 저장
  Future<Map<String, dynamic>> saveClosetItem({
    required String userId,
    required String imageUrl,
    required String style,
    required int size,
    required String part,
  }) async {
    try {
      final docRef = await _firestore.collection('users/$userId/images').add({
        'imageUrl': imageUrl,
        'style': style,
        'size': size,
        'part': part,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final docSnapshot = await docRef.get();
      final newItem = ClosetItem.fromFirestore(docSnapshot);

      return {
        'item': newItem,
        'error': null,
      };
    } catch (e) {
      return {
        'item': null,
        'error': 'Failed to save closet item: $e',
      };
    }
  }
}