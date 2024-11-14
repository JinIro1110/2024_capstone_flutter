import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/MallItem.dart';

class MallRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MallRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance {
    _initializeFirestore();
  }

  void _initializeFirestore() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Query<Map<String, dynamic>> _buildQuery(String category, int limit) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('items')
        .orderBy('Code', descending: true);
    
    if (category != '전체') {
      query = query.where('Category.Main', isEqualTo: category);
    }
    
    return query.limit(limit);
  }

  Future<List<MallItem>> fetchItems({
    required String category,
    required int limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      var query = _buildQuery(category, limit);
      
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) return [];

      return await Future.wait(
        snapshot.docs.map((doc) => _createMallItem(doc))
      );
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  Future<MallItem> _createMallItem(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>;
      String imageUrl = '';
      
      try {
        final storageRef = _storage.ref().child('items/${doc.id}.jpg');
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        print('Error fetching image URL for ${doc.id}: $e');
        // Provide a fallback image URL or leave empty
        imageUrl = '';
      }

      return MallItem(
        code: data['Code']?.toString() ?? '',
        name: data['Name'] ?? '',
        price: data['Price']?.toString() ?? '',
        brand: data['Brand'] ?? '',
        category: '${data['Category']?['Main'] ?? ''} > ${data['Category']?['Sub'] ?? ''}',
        mainCategory: data['Category']?['Main'] ?? '',
        subCategory: data['Category']?['Sub'] ?? '',
        imageUrl: imageUrl,
        link: data['Link'] ?? '',
      );
    } catch (e) {
      print('Error creating MallItem from document ${doc.id}: $e');
      // Return a default MallItem or rethrow based on your error handling strategy
      throw Exception('Failed to create MallItem from document');
    }
  }

  // Add a method to fetch a single item by code
  Future<MallItem?> fetchItemByCode(String code) async {
    try {
      final snapshot = await _firestore
          .collection('items')
          .where('Code', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return await _createMallItem(snapshot.docs.first);
    } catch (e) {
      print('Error fetching item by code: $e');
      return null;
    }
  }

  // Add a method to fetch items by brand
  Future<List<MallItem>> fetchItemsByBrand(String brand, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('items')
          .where('Brand', isEqualTo: brand)
          .orderBy('Code', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return await Future.wait(
        snapshot.docs.map((doc) => _createMallItem(doc))
      );
    } catch (e) {
      print('Error fetching items by brand: $e');
      return [];
    }
  }
}