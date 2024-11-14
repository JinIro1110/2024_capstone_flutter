import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/alert.dart';
import 'package:flutter_application_1/models/PreferencesScreen.dart';
import 'package:flutter_application_1/screens/recommend/color_screen.dart';

class PurposeScreen extends StatefulWidget {
  final List<String> selectedStyles;
  final List<String> selectedPatterns;

  const PurposeScreen({
    Key? key,
    required this.selectedStyles,
    required this.selectedPatterns,
  }) : super(key: key);

  @override
  _PurposeScreenState createState() => _PurposeScreenState();
}

class _PurposeScreenState extends State<PurposeScreen> {
  // 용도 목록
  final List<String> purposes = ['데일리', '출근', '데이트', '운동', '파티'];

  // 선택된 용도를 저장하는 변수
  String? selectedPurpose;

  void _handlePurposeSelection(String purpose) {
    setState(() {
      selectedPurpose = selectedPurpose == purpose ? null : purpose;
    });
  }

  void _handleNextButton() {
    if (selectedPurpose == null) {
      showDialog(
        context: context,
        builder: (context) => Alert(
          title: '용도 선택',
          content: '용도를 선택해주세요.',
          onConfirm: () {
            // 확인 버튼 클릭 시 추가 작업이 있을 경우 작성
          },
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ColorScreen(
            selectedStyles: widget.selectedStyles,
            selectedPatterns: widget.selectedPatterns,
            selectedPurposes: [selectedPurpose!],  // 선택된 용도만 전달
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('용도 선택'),
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
              itemCount: purposes.length,
              itemBuilder: (context, index) {
                final purpose = purposes[index];
                final isSelected = selectedPurpose == purpose;

                return PreferencesCard(
                  label: purpose,
                  isSelected: isSelected,
                  onTap: () => _handlePurposeSelection(purpose),
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
