// 사용자 취향 데이터를 저장하는 클래스: 스타일, 패턴, 목적, 색상 리스트 포함
class PreferenceData {
  final List<String> styles;    // 스타일 목록
  final List<String> patterns;  // 패턴 목록
  final List<String> purposes;  // 목적 목록
  final List<String> colors;    // 색상 목록

  PreferenceData({
    required this.styles,
    required this.patterns,
    required this.purposes,
    required this.colors,
  });
}
