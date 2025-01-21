import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';

// 옷장 아이템 정보를 나타내는 데이터 클래스
class ClosetItem {
  final String id; // Firestore 문서 ID
  final String imageUrl; // 아이템 이미지 URL
  final String style; // 스타일 정보
  final int size; // 사이즈 정보
  final String part; // 아이템 부위 (예: 상의, 하의)

  // 생성자를 통해 모든 필드를 초기화
  ClosetItem({
    required this.id,
    required this.imageUrl,
    required this.style,
    required this.size,
    required this.part,
  });

  // Firestore 문서를 ClosetItem 객체로 변환하는 팩토리 생성자
  factory ClosetItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Firestore 데이터 추출
    return ClosetItem(
      id: doc.id, // Firestore 문서 ID 사용
      imageUrl: data['imageUrl'], // 이미지 URL
      style: data['style'], // 스타일 정보
      size: data['size'], // 사이즈 정보
      part: data['part'], // 부위 정보
    );
  }
}

// 옷장 아이템을 카드 형태로 UI에 표시하는 위젯
class ClothingItemCard extends StatelessWidget {
  final ClosetItem item; // 표시할 옷장 아이템
  final bool isSelected; // 선택 여부를 나타내는 플래그
  final VoidCallback onToggleSelection; // 선택 상태 변경 콜백

  const ClothingItemCard({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onToggleSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleSelection, // 카드 클릭 시 선택 상태 변경
      child: Card(
        elevation: 4, // 카드 그림자 효과
        color: isSelected ? AppColors.lavender : Colors.white, // 선택 시 배경색 변경
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 처리
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지 섹션
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                item.imageUrl, // 네트워크에서 이미지를 로드
                fit: BoxFit.cover, // 이미지 크기 조정
                height: 120, // 고정 높이
                width: double.infinity, // 가로 크기를 카드 전체로 확장
              ),
            ),
            // 정보 섹션
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // 텍스트 가운데 정렬
                children: [
                  // 스타일 정보 텍스트
                  Text(
                    '스타일: ${item.style}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2, // 최대 2줄로 제한
                    overflow: TextOverflow.ellipsis, // 텍스트가 길 경우 생략 표시
                    textAlign: TextAlign.center, // 가운데 정렬
                  ),
                  const SizedBox(height: 4), // 간격 추가
                  // 사이즈 정보 텍스트
                  Text(
                    '사이즈: ${item.size}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  // 부위 정보 텍스트
                  Text(
                    '부위: ${item.part}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
