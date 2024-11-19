import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'package:flutter_application_1/models/preferencesData.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'dart:convert';

class ResultScreen extends StatelessWidget {
  final PreferenceData preferenceData;

  const ResultScreen({Key? key, required this.preferenceData})
      : super(key: key);

  Future<void> _sendPreferenceToServer() async {
    // Firebase에서 현재 로그인된 사용자 정보 가져오기
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("사용자가 로그인되지 않았습니다.");
      return;
    }

    final userId = user.uid; // 로그인된 사용자의 UID 가져오기
    final url = Uri.parse('http://172.18.109.84:3000/data'); // 서버 URL

    final data = {
      'userId': userId,
      'styles': preferenceData.styles,
      'patterns': preferenceData.patterns,
      'purposes': preferenceData.purposes,
      'colors': preferenceData.colors,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('데이터 전송 성공');
      } else {
        print('데이터 전송 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

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
                onPressed: () async {
                  await _sendPreferenceToServer(); // 서버로 데이터 전송
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
