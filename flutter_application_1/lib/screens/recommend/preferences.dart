// style_preferences_screen.dart
import 'package:flutter/material.dart';

class StylePreferencesScreen extends StatefulWidget {
  const StylePreferencesScreen({super.key});

  @override
  _StylePreferencesScreenState createState() => _StylePreferencesScreenState();
}

class _StylePreferencesScreenState extends State<StylePreferencesScreen> {
  String? selectedStyle;
  String? selectedPattern;
  String? selectedPurpose;
  Color? selectedColor;
  final Map<String, dynamic> preferences = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 스타일 취향'),
        backgroundColor: const Color.fromARGB(224, 86, 98, 112),
      ),
      body: PageView(
        children: [
          _buildStyleSelection(),
          _buildPatternSelection(),
          _buildPurposeSelection(),
          _buildColorSelection(),
        ],
      ),
    );
  }

  Widget _buildStyleSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            '당신의 스타일을 선택해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStyleCard('캐주얼', 'assets/casual.png'),
              _buildStyleCard('포멀', 'assets/formal.png'),
              _buildStyleCard('스트릿', 'assets/street.png'),
              _buildStyleCard('빈티지', 'assets/vintage.png'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyleCard(String style, String imagePath) {
    bool isSelected = selectedStyle == style;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedStyle = style;
            preferences['style'] = style;
          });
        },
        child: Card(
          elevation: isSelected ? 8 : 4,
          color: isSelected ? const Color.fromARGB(224, 165, 147, 224) : Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.style, size: 48),
              const SizedBox(height: 8),
              Text(style, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatternSelection() {
    List<String> patterns = ['체크무늬', '줄무늬', '단색', '꽃무늬'];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            '선호하는 패턴을 선택해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: patterns.map((pattern) {
              bool isSelected = selectedPattern == pattern;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 160 : 150,
                height: isSelected ? 60 : 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected 
                        ? const Color.fromARGB(224, 165, 147, 224)
                        : Colors.white,
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedPattern = pattern;
                      preferences['pattern'] = pattern;
                    });
                  },
                  child: Text(pattern),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeSelection() {
    List<String> purposes = ['직장', '데일리', '여행', '행사'];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            '의류의 목적을 선택해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: purposes.length,
            itemBuilder: (context, index) {
              String purpose = purposes[index];
              bool isSelected = selectedPurpose == purpose;
              return Card(
                color: isSelected ? const Color.fromARGB(224, 165, 147, 224) : Colors.white,
                child: ListTile(
                  title: Text(purpose),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      selectedPurpose = purpose;
                      preferences['occasion'] = purpose;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.black,
      Colors.white,
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            '선호하는 색상을 선택해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedColor = colors[index];
                      preferences['color'] = colors[index].toString();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors[index],
                      border: Border.all(
                        color: selectedColor == colors[index]
                            ? const Color.fromARGB(224, 165, 147, 224)
                            : Colors.grey,
                        width: selectedColor == colors[index] ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(224, 165, 147, 224),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: () {
              if (selectedStyle != null &&
                  selectedPattern != null &&
                  selectedPurpose != null &&
                  selectedColor != null) {
                print('선택된 취향:');
                print('스타일: $selectedStyle');
                print('패턴: $selectedPattern');
                print('목적: $selectedPurpose');
                print('색상: $selectedColor');
                Navigator.pop(context, preferences);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('모든 항목을 선택해주세요')),
                );
              }
            },
            child: const Text('완료', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}