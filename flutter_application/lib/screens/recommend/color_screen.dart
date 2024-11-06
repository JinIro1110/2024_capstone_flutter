import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/Alert.dart';
import 'package:flutter_application_1/models/PreferencesScreen.dart';
import 'package:flutter_application_1/models/preferencesData.dart';
import 'package:flutter_application_1/screens/recommend/result_screen.dart';

class ColorScreen extends StatefulWidget {
  final List<String> selectedStyles;
  final List<String> selectedPatterns;
  final List<String> selectedPurposes;

  const ColorScreen({
    Key? key,
    required this.selectedStyles,
    required this.selectedPatterns,
    required this.selectedPurposes,
  }) : super(key: key);

  @override
  _ColorScreenState createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  final List<ColorOption> colors = [
    ColorOption('블랙', Colors.black),
    ColorOption('화이트', Colors.white),
    ColorOption('그레이', Colors.grey),
    ColorOption('베이지', Color(0xFFE8D6B3)),
    ColorOption('네이비', Color(0xFF000080)),
  ];

  String? selectedColor;

  void _handleColorSelection(String color) {
    setState(() {
      selectedColor = selectedColor == color ? null : color;
    });
  }

  void _handleNextButton() {
    if (selectedColor == null) {
      showDialog(
        context: context,
        builder: (context) => Alert(
          title: '색상 선택',
          content: '색상을 선택해주세요.',
          onConfirm: () {
            // 확인 버튼 클릭 시 추가 작업이 있을 경우 작성
          },
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            preferenceData: PreferenceData(
              styles: widget.selectedStyles,
              patterns: widget.selectedPatterns,
              purposes: widget.selectedPurposes,
              colors: [selectedColor!],  // 하나의 색상만 전달
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('색상 선택'),
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
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = selectedColor == color.name;

                return PreferencesCard(
                  label: color.name,
                  isSelected: isSelected,
                  onTap: () => _handleColorSelection(color.name),
                  circleColor: color.color,
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

class ColorOption {
  final String name;
  final Color color;

  ColorOption(this.name, this.color);
}
