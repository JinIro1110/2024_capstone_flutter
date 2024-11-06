import 'package:cloud_firestore/cloud_firestore.dart';

class ClosetItem {
  final String imageUrl;
  final String style;
  final int size;

  ClosetItem({
    required this.imageUrl,
    required this.style,
    required this.size,
  });

  factory ClosetItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClosetItem(
      imageUrl: data['imageUrl'],
      style: data['style'],
      size: data['size'],
    );
  }
}
