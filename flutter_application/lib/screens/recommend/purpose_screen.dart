import 'package:flutter/material.dart';
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
  final List<String> purposes = ['데일리', '출근', '데이트', '운동', '파티'];
  List<String> selectedPurposes = [];

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
            child: ListView.builder(
              itemCount: purposes.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(purposes[index]),
                  value: selectedPurposes.contains(purposes[index]),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedPurposes.add(purposes[index]);
                      } else {
                        selectedPurposes.remove(purposes[index]);
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
                    builder: (context) => ColorScreen(
                      selectedStyles: widget.selectedStyles,
                      selectedPatterns: widget.selectedPatterns,
                      selectedPurposes: selectedPurposes,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(224, 165, 147, 224),
              ),
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }
}