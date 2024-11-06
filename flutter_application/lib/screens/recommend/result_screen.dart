import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/preferencesData.dart';

class ResultScreen extends StatelessWidget {
  final PreferenceData preferenceData;

  const ResultScreen({Key? key, required this.preferenceData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('선택 결과'),
        backgroundColor: const Color.fromARGB(224, 86, 98, 112),
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
          ],
        ),
      ),
    );
  }
}