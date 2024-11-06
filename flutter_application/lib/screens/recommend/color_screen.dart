import 'package:flutter/material.dart';
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
  final List<String> colors = ['블랙', '화이트', '그레이', '베이지', '네이비'];
  List<String> selectedColors = [];

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
            child: ListView.builder(
              itemCount: colors.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(colors[index]),
                  value: selectedColors.contains(colors[index]),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedColors.add(colors[index]);
                      } else {
                        selectedColors.remove(colors[index]);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      preferenceData: PreferenceData(
                        styles: widget.selectedStyles,
                        patterns: widget.selectedPatterns,
                        purposes: widget.selectedPurposes,
                        colors: selectedColors,
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(224, 165, 147, 224),
              ),
              child: const Text('완료'),
            ),
          ),
        ],
      ),
    );
  }
}