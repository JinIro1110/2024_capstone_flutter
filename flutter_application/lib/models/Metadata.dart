import 'package:flutter/material.dart';

// 옷 메타데이터를 나타내는 클래스
// - 스타일, 사이즈, 부위를 포함합니다.
class ClothingMetadata {
  final String style; // 옷의 스타일 (예: 캐주얼, 스포티)
  final int size; // 옷의 사이즈
  final String part; // 옷의 부위 (예: 상의, 하의)

  // 생성자를 통해 필드를 초기화
  ClothingMetadata({
    required this.style,
    required this.size,
    required this.part,
  });
}

// 옷 메타데이터를 입력받기 위한 다이얼로그 위젯
// - 스타일, 사이즈, 부위를 선택할 수 있습니다.
class MetadataInputDialog extends StatefulWidget {
  const MetadataInputDialog({Key? key}) : super(key: key);

  @override
  _MetadataInputDialogState createState() => _MetadataInputDialogState();
}

class _MetadataInputDialogState extends State<MetadataInputDialog> {
  // 초기 선택값
  String selectedPart = '상의'; // 기본값: 상의
  String selectedStyle = '캐주얼'; // 기본값: 캐주얼 스타일
  int selectedSize = 95; // 기본값: 95 사이즈

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('데이터 입력'), // 다이얼로그 제목
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용 크기만큼 다이얼로그 크기 조정
          children: [
            /// 스타일 드롭다운
            /// - 캐주얼, 스포티, 스트릿 중 선택
            DropdownButton<String>(
              value: selectedStyle,
              onChanged: (newValue) {
                setState(() {
                  selectedStyle = newValue!;
                });
              },
              items: <String>['캐주얼', '스포티', '스트릿']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            // 사이즈 드롭다운
            // - 85부터 120까지 5단위로 선택
            DropdownButton<int>(
              value: selectedSize,
              onChanged: (newValue) {
                setState(() {
                  selectedSize = newValue!;
                });
              },
              items: List.generate(8, (index) => 85 + index * 5) // 85 ~ 120
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
            ),

            // 부위 드롭다운
            // - 상의 또는 하의 중 선택
            DropdownButton<String>(
              value: selectedPart,
              onChanged: (newValue) {
                setState(() {
                  selectedPart = newValue!;
                });
              },
              items: <String>['상의', '하의']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        // 저장 버튼
        // - 입력된 데이터를 `ClothingMetadata` 객체로 반환
        TextButton(
          child: const Text('저장'),
          onPressed: () {
            if (selectedStyle.isNotEmpty && selectedSize > 0) {
              Navigator.pop(
                context,
                ClothingMetadata(
                  style: selectedStyle,
                  size: selectedSize,
                  part: selectedPart,
                ),
              );
            } else {
              // 필드가 비어있을 경우 경고 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('모든 필드를 채워주세요.')),
              );
            }
          },
        ),
        // 취소 버튼
        // - 다이얼로그를 닫음
        TextButton(
          child: const Text('취소'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
