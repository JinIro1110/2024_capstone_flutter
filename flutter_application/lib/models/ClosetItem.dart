import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';

class ClosetItem {
  final String id; // ID 필드 추가
  final String imageUrl;
  final String style;
  final int size;
  final String part; // 상의 또는 하의로 구분

  ClosetItem({
    required this.id, // ID를 생성자에 추가
    required this.imageUrl,
    required this.style,
    required this.size,
    required this.part,
  });

  factory ClosetItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClosetItem(
      id: doc.id, // Firestore 문서의 ID를 사용
      imageUrl: data['imageUrl'],
      style: data['style'],
      size: data['size'],
      part: data['part'],
    );
  }
}

class ClothingItemCard extends StatelessWidget {
  final ClosetItem item;
  final bool isSelected;
  final VoidCallback onToggleSelection;

  const ClothingItemCard({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onToggleSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleSelection, // 선택/해제 처리
      child: Card(
        elevation: 4,
        color: isSelected ? AppColors.lavender : Colors.white, // 선택된 경우 색상 변경
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '스타일: ${item.style}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text('사이즈: ${item.size}', style: const TextStyle(fontSize: 14)),
                  Text('부위: ${item.part}', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
