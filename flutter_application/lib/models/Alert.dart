import 'package:flutter/material.dart';

class Alert extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const Alert({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            onConfirm(); // 확인 버튼 클릭 시 실행
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}
