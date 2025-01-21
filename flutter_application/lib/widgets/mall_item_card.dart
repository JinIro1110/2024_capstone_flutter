import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/models/MallItem.dart';
import 'package:flutter_application_1/utils/constants.dart';

// 쇼핑몰 아이템 카드
class MallItemCard extends StatelessWidget {
  final MallItem item; // 아이템 정보
  final VoidCallback? onLikePressed; // 좋아요 버튼 클릭 시 호출
  final VoidCallback? onBuyPressed; // 구매 버튼 클릭 시 호출

  const MallItemCard({
    Key? key, 
    required this.item,
    this.onLikePressed,
    this.onBuyPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedPrice = '${int.parse(item.price).toLocaleString()}원'; // 가격 포맷팅

    return Card(
      elevation: 5, // 그림자 효과
      clipBehavior: Clip.antiAlias, // 클립 설정
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // 카드 모서리 둥글게
      ),
      child: SizedBox(
        height: 500, // 카드 높이
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Expanded(
              flex: 10, // 이미지 부분 비율
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey[100], // 배경 색상
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl, // 이미지 URL
                        fit: BoxFit.contain, // 이미지 크기 조정
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, // 로딩 인디케이터 두께
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(224, 165, 147, 224),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.error, color: Colors.red, size: 20), // 에러 아이콘
                        ),
                      ),
                    ),
                  ),
                  if (onLikePressed != null)
                    Positioned(
                      top: 8, // 좋아요 버튼 위치
                      right: 8,
                      child: _buildLikeButton(),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0), // 내부 여백
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                mainAxisSize: MainAxisSize.min, // 최소 크기
                children: [
                  Text(
                    item.brand, // 브랜드명
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // 굵게
                      fontSize: 12, // 폰트 크기
                      color: Colors.grey[700], // 텍스트 색상
                    ),
                    maxLines: 1, // 한 줄 제한
                    overflow: TextOverflow.ellipsis, // 말줄임표
                  ),
                  const SizedBox(height: 4), // 간격
                  Text(
                    item.name, // 아이템 이름
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2, // 최대 두 줄
                    overflow: TextOverflow.ellipsis, // 말줄임표
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedPrice, // 가격
                    style: const TextStyle(
                      color: Color.fromARGB(224, 165, 147, 224), // 가격 색상
                      fontWeight: FontWeight.bold, // 굵게
                      fontSize: 14, // 폰트 크기
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (onBuyPressed != null)
                    _buildBuyButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 좋아요 버튼
  Widget _buildLikeButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle, // 원형
        color: Colors.black.withOpacity(0.5), // 반투명 검정색
      ),
      child: IconButton(
        icon: const Icon(
          Icons.favorite_border, // 아이콘
          color: Colors.white, // 아이콘 색상
          size: 16, // 아이콘 크기
        ),
        padding: EdgeInsets.zero, // 패딩 제거
        onPressed: onLikePressed, // 클릭 시 호출
      ),
    );
  }

  // 구매 버튼
  Widget _buildBuyButton() {
    return SizedBox(
      width: double.infinity, // 너비 최대
      height: 32, // 높이
      child: ElevatedButton(
        onPressed: onBuyPressed, // 클릭 시 호출
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy, // 버튼 색상
          foregroundColor: Colors.white, // 텍스트 색상
          padding: EdgeInsets.zero, // 패딩 제거
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 모서리 둥글게
          ),
        ),
        child: const Text(
          '구매하기', // 버튼 텍스트
          style: TextStyle(
            fontSize: 12, // 폰트 크기
            fontWeight: FontWeight.bold, // 굵게
          ),
        ),
      ),
    );
  }
}

// 숫자 포맷 확장
extension NumberFormat on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},', // 천 단위 콤마 추가
    );
  }
}
