import 'package:flutter/material.dart';

class StyleScreen extends StatefulWidget {
  const StyleScreen({Key? key}) : super(key: key);

  @override
  _StyleScreenState createState() => _StyleScreenState();
}

class _StyleScreenState extends State<StyleScreen> {
  final List<String> styles = ['캐주얼', '포멀', '스포티', '빈티지', '모던'];
  List<String> selectedStyles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스타일 선택'),
        backgroundColor: const Color.fromARGB(224, 86, 98, 112),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: styles.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(styles[index]),
                  value: selectedStyles.contains(styles[index]),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedStyles.add(styles[index]);
                      } else {
                        selectedStyles.remove(styles[index]);
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
                    builder: (context) => PatternScreen(selectedStyles: selectedStyles),
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