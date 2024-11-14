import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/alert.dart';
import 'package:flutter_application_1/models/PreferencesScreen.dart';
import 'package:flutter_application_1/screens/recommend/purpose_screen.dart';

class PatternScreen extends StatefulWidget {
  final List<String> selectedStyles;

  const PatternScreen({Key? key, required this.selectedStyles}) : super(key: key);

  @override
  _PatternScreenState createState() => _PatternScreenState();
}

class _PatternScreenState extends State<PatternScreen> {
  // 패턴 목록
  final List<String> patterns = ['무지', '체크', '스트라이프', '도트', '플로럴'];

  // 선택된 패턴을 저장하는 변수
  String? selectedPattern;

  void _handlePatternSelection(String pattern) {
    setState(() {
      selectedPattern = selectedPattern == pattern ? null : pattern;
    });
  }

  void _handleNextButton() {
    if (selectedPattern == null) {
      showDialog(
        context: context,
        builder: (context) => Alert(
          title: '패턴 선택',
          content: '패턴을 선택해주세요.',
          onConfirm: () {
            // 확인 버튼 클릭 시 추가 작업이 있을 경우 작성
          },
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PurposeScreen(
            selectedStyles: widget.selectedStyles,
            selectedPatterns: [selectedPattern!], // 선택된 패턴만 전달
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('패턴 선택'),
        backgroundColor: const Color.fromARGB(224, 86, 98, 112),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: patterns.length,
              itemBuilder: (context, index) {
                final pattern = patterns[index];
                final isSelected = selectedPattern == pattern;

                return PreferencesCard(
                  label: pattern,
                  isSelected: isSelected,
                  onTap: () => _handlePatternSelection(pattern),
                );
              },
            ),
          ),
          NextButton(
            onPressed: _handleNextButton,
          ),
        ],
      ),
    );
  }
}
