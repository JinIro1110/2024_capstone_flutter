import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/preferencesData.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/utils/constants.dart';

class ResultScreen extends StatelessWidget {
  final PreferenceData preferenceData;

  const ResultScreen({Key? key, required this.preferenceData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('선택한 스타일: ${preferenceData.styles.join(", ")}'),
            const SizedBox(height: 16),
            Text('선택한 패턴: ${preferenceData.patterns.join(", ")}'),
            const SizedBox(height: 16),
            Text('선택한 용도: ${preferenceData.purposes.join(", ")}'),
            const SizedBox(height: 16),
            Text('선택한 색상: ${preferenceData.colors.join(", ")}'),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 네비게이션 스택을 모두 제거하고 MyHomePage로 이동
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60),
                ),
                child: const Text('메인 화면으로 돌아가기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
