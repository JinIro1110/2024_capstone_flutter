import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:flutter_application_1/widgets/alert.dart';
import 'package:flutter_application_1/models/PreferencesScreen.dart';
import 'package:flutter_application_1/screens/recommend/result_screen.dart';

class StyleScreen extends StatefulWidget {
  const StyleScreen({Key? key}) : super(key: key);

  @override
  _StyleScreenState createState() => _StyleScreenState();
}

class _StyleScreenState extends State<StyleScreen> {
  final List<String> styles = ['캐주얼', '스포티', '스트릿/빈티지'];
  String? selectedStyle;

  void _handleStyleSelection(String style) {
    setState(() {
      selectedStyle = style;
    });
  }

// 확인 다이얼로그 창
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        title: Text(
          '스타일 선택 확인',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        content: Text(
          '선택하신 스타일 "$selectedStyle"이(가) 맞나요?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              // 다음 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ResultScreen(selectedStyle: selectedStyle!),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            child: Text(
              '확인',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            child: Text(
              '취소',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

// 다음 페이지로 넘어가기
  void _handleNextButton() {
    if (selectedStyle == null) {
      // 스타일을 선택하지 않았을 때 경고 다이얼로그
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Text(
            '스타일 선택',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          content: Text(
            '스타일을 선택해주세요.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 스타일을 선택했을 때 확인 다이얼로그 표시
      _showConfirmationDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
