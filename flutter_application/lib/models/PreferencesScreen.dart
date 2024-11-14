import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';

class PreferencesCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? circleColor; // 선택적으로 사용할 circleColor

  const PreferencesCard({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.circleColor, // circleColor는 null로 설정, 필요한 경우만 넘김
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: isSelected
            ? AppColors.blue
            : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // circleColor가 null이 아닐 때만 원형 색상 표시
            if (circleColor != null) 
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: circleColor, // circleColor 적용
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
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

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
          backgroundColor: AppColors.navy,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}