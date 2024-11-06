import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/Alert.dart';
import 'package:flutter_application_1/models/PreferencesScreen.dart';
import 'package:flutter_application_1/screens/recommend/pattern_screen.dart';

class StyleScreen extends StatefulWidget {
  const StyleScreen({Key? key}) : super(key: key);

  @override
  _StyleScreenState createState() => _StyleScreenState();
}

class _StyleScreenState extends State<StyleScreen> {
  final List<String> styles = ['캐주얼', '포멀', '스포티', '빈티지', '모던'];
  String? selectedStyle;

  void _handleStyleSelection(String style) {
    setState(() {
      selectedStyle = style;
    });
  }

  void _handleNextButton() {
    if (selectedStyle == null) {
      showDialog(
        context: context,
        builder: (context) => Alert(
          title: '스타일 선택',
          content: '스타일을 선택해주세요.',
          onConfirm: () {
            // 확인 버튼 클릭 시 수행할 작업이 있다면 여기에 추가
          },
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatternScreen(selectedStyles: [selectedStyle!]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '스타일 선택',
          style: TextStyle(color: Colors.white),
        ),
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
              itemCount: styles.length,
              itemBuilder: (context, index) {
                final style = styles[index];
                return PreferencesCard(
                  label: style,
                  isSelected: selectedStyle == style,
                  onTap: () => _handleStyleSelection(style),
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