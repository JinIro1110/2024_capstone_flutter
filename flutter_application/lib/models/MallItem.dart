// 쇼핑몰 아이템 정보를 나타내는 데이터 클래스
class MallItem {
  final String code; // 상품 고유 코드
  final String name; // 상품 이름
  final String price; // 상품 가격
  final String brand; // 브랜드 이름
  final String category; // 카테고리 (예: 의류, 신발)
  final String mainCategory; // 대카테고리 (예: 남성복, 여성복)
  final String subCategory; // 소카테고리 (예: 티셔츠, 바지)
  final String imageUrl; // 상품 이미지 URL
  final String link; // 상품 상세 페이지 링크

  // 생성자를 통해 모든 필드를 초기화
  MallItem({
    required this.code,
    required this.name,
    required this.price,
    required this.brand,
    required this.category,
    required this.mainCategory,
    required this.subCategory,
    required this.imageUrl,
    required this.link,
  });
}
