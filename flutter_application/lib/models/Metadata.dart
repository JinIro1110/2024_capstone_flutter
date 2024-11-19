import 'package:flutter/material.dart';

class ClothingMetadata {
  final String style;
  final int size;
  final String part;

  ClothingMetadata({
    required this.style,
    required this.size,
    required this.part,
  });
}

class MetadataInputDialog extends StatefulWidget {
  const MetadataInputDialog({Key? key}) : super(key: key);

  @override
  _MetadataInputDialogState createState() => _MetadataInputDialogState();
}

class _MetadataInputDialogState extends State<MetadataInputDialog> {
  String selectedPart = '상의'; // 기본값
  String selectedStyle = '스타일 1'; // 기본 스타일
  int selectedSize = 95; // 기본 사이즈

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('데이터 입력'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 스타일 드롭다운 (5개 스타일)
            DropdownButton<String>(
              value: selectedStyle,
              onChanged: (newValue) {
                setState(() {
                  selectedStyle = newValue!;
                });
              },
              items: <String>['스타일 1', '스타일 2', '스타일 3', '스타일 4', '스타일 5']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // 사이즈 드롭다운 (85 ~ 120 사이즈, 5단위)
            DropdownButton<int>(
              value: selectedSize,
              onChanged: (newValue) {
                setState(() {
                  selectedSize = newValue!;
                });
              },
              items: List.generate(8, (index) => 85 + index * 5) // 85부터 120까지 5단위
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
            ),
            // 부위 드롭다운 (상의, 하의)
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
        TextButton(
          child: const Text('저장'),
          onPressed: () {
            // 선택된 값이 모두 유효하면 클로징
            if (selectedStyle.isNotEmpty && selectedSize > 0) {
              Navigator.pop(
                context,
                ClothingMetadata(style: selectedStyle, size: selectedSize, part: selectedPart),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
            }
          },
        ),
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
