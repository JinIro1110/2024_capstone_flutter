import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/recommend/purpose_screen.dart';

class PatternScreen extends StatefulWidget {
  final List<String> selectedStyles;

  const PatternScreen({Key? key, required this.selectedStyles}) : super(key: key);

  @override
  _PatternScreenState createState() => _PatternScreenState();
}

class _PatternScreenState extends State<PatternScreen> {
  final List<String> patterns = ['무지', '체크', '스트라이프', '도트', '플로럴'];
  List<String> selectedPatterns = [];

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
            child: ListView.builder(
              itemCount: patterns.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(patterns[index]),
                  value: selectedPatterns.contains(patterns[index]),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedPatterns.add(patterns[index]);
                      } else {
                        selectedPatterns.remove(patterns[index]);
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
                    builder: (context) => PurposeScreen(
                      selectedStyles: widget.selectedStyles,
                      selectedPatterns: selectedPatterns,
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