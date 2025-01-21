import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';

/// 커스텀 AlertDialog 위젯
class Alert extends StatelessWidget {
  final String title;  // 다이얼로그 타이틀
  final String content;  // 다이얼로그 내용
  final VoidCallback onConfirm;  // 확인 버튼 클릭 시 실행할 콜백 함수

  const Alert({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 다이얼로그의 모서리를 둥글게 만듦
      ),
      backgroundColor: Colors.white,  // 다이얼로그 배경 색상
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,  // 타이틀 색상
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,  // 다이얼로그 내용 텍스트 색상
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onConfirm();  // 확인 버튼 클릭 시 콜백 함수 실행
            Navigator.of(context).pop();  // 다이얼로그 닫기
          },
          style: TextButton.styleFrom(
            backgroundColor: AppColors.navy,  // 버튼 배경 색상
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),  // 버튼 모서리 둥글게 만듦
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
          child: Text(
            '확인',
            style: TextStyle(
              color: Colors.white,  // 버튼 텍스트 색상
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
