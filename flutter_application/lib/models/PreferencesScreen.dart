import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';

// 사용자 선호도를 카드 형태로 보여주는 위젯: 선택 여부에 따라 색상 변경
class PreferencesCard extends StatelessWidget {
  final String label;         // 카드 레이블
  final bool isSelected;      // 선택 여부
  final VoidCallback onTap;   // 카드 클릭 이벤트 콜백
  final Color? circleColor;   // 선택적으로 적용될 원형 색상

  const PreferencesCard({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.circleColor,  // circleColor가 필요 없는 경우 null로 설정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: isSelected ? AppColors.blue : Colors.white, // 선택 여부에 따른 배경 색상
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // circleColor가 설정된 경우에만 원형 색상 표시
            if (circleColor != null) 
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : Colors.black,  // 선택 여부에 따라 텍스트 색상 변경
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 다음 버튼 위젯: 사용자 인터페이스 내 버튼 역할
class NextButton extends StatelessWidget {
  final VoidCallback onPressed;  // 버튼 클릭 이벤트 콜백
  final String label;            // 버튼 레이블, 기본 값 '다음'

  const NextButton({
    Key? key,
    required this.onPressed,
    this.label = '다음',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,  // 버튼 배경 색상 설정
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,  // 버튼 텍스트 색상 설정
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
