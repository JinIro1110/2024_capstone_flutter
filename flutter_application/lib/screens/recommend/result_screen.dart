import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:provider/provider.dart';


// 결과창
class ResultScreen extends StatefulWidget {
  final String selectedStyle;

  const ResultScreen({Key? key, required this.selectedStyle}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Map<String, dynamic>> topItems = [];
  List<Map<String, dynamic>> bottomItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  Map<String, dynamic>? selectedTop;
  Map<String, dynamic>? selectedBottom;

  @override
  void initState() {
    super.initState();
    _fetchRandomItems();
  }

  Future<String> _getImageUrl(String documentId) async {
    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('items/$documentId.jpg');
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error fetching image URL: $e');
      return ''; // 이미지를 가져오지 못한 경우 빈 문자열 반환
    }
  }

  Future<void> _fetchRandomItems() async {
    try {
      // 모든 아이템 가져오기
      final topQuery = await FirebaseFirestore.instance
          .collection('items')
          .where('Category.Main', isEqualTo: '상의')
          .where('Category.Sub', isEqualTo: widget.selectedStyle)
          .get();

      final bottomQuery = await FirebaseFirestore.instance
          .collection('items')
          .where('Category.Main', isEqualTo: '하의')
          .where('Category.Sub', isEqualTo: widget.selectedStyle)
          .get();

      // 랜덤 셔플
      final random = Random();

      List<Map<String, dynamic>> shuffledTopItems = topQuery.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList()
        ..shuffle(random);

      List<Map<String, dynamic>> shuffledBottomItems = bottomQuery.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList()
        ..shuffle(random);

      // 이미지 URL 추가 로직 (기존 코드와 동일)
      final List<Map<String, dynamic>> topItemsWithImages = [];
      for (var item in shuffledTopItems.take(3)) {
        String imageUrl = '';
        try {
          final Reference storageRef =
              FirebaseStorage.instance.ref().child('items/${item['id']}.jpg');
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          print('Image not found for document ${item['id']}: $e');
        }

        topItemsWithImages.add({'ImageUrl': imageUrl, ...item});
      }

      // 하의 아이템도 동일한 방식으로 처리
      final List<Map<String, dynamic>> bottomItemsWithImages = [];
      for (var item in shuffledBottomItems.take(3)) {
        String imageUrl = '';
        try {
          final Reference storageRef =
              FirebaseStorage.instance.ref().child('items/${item['id']}.jpg');
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          print('Image not found for document ${item['id']}: $e');
        }

        bottomItemsWithImages.add({'ImageUrl': imageUrl, ...item});
      }

      setState(() {
        topItems = topItemsWithImages;
        bottomItems = bottomItemsWithImages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '아이템을 불러오는 중 오류가 발생했습니다.';
      });
      print('Error fetching items: $e');
    }
  }

  void _selectTop(Map<String, dynamic> top) {
    setState(() {
      selectedTop = top;
    });
  }

  void _selectBottom(Map<String, dynamic> bottom) {
    setState(() {
      selectedBottom = bottom;
    });
  }

  Future<void> _handleNextStep() async {
    if (selectedTop != null && selectedBottom != null) {
      String? outfitName = await _showNameInputDialog(context);

      if (outfitName != null && outfitName.isNotEmpty) {
        try {
          LoginAuth loginAuth = Provider.of<LoginAuth>(context, listen: false);
          String? userId = loginAuth.user?.uid;

          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('로그인 정보가 없습니다.')),
            );
            return;
          }

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.navy),
                    SizedBox(height: 16),
                    Text(
                      '모델 생성 중입니다.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 40),
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
                  ),
                ],
              );
            },
          );

          // 백그라운드에서 서버로 데이터 전송
          sendOutfitDataToServer(
            userId: userId,
            context: context,
            selectedTop: selectedTop!,
            selectedBottom: selectedBottom!,
            outfitName: outfitName,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류가 발생했습니다.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('코디 이름을 입력해주세요.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상의와 하의를 모두 선택해주세요.')),
      );
    }
  }

// 스타일 이름 저장
  Future<String?> _showNameInputDialog(BuildContext context) async {
    String? outfitName;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Text(
            '코디 이름 입력',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          content: TextField(
            decoration: InputDecoration(
              hintText: '코디 이름을 입력해주세요',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.navy),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.navy, width: 2),
              ),
            ),
            onChanged: (value) {
              outfitName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(outfitName),
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(
      Map<String, dynamic> item, bool isSelected, VoidCallback onTap) {
    final formattedPrice =
        '${int.parse(item['Price'].toString()).toLocaleString()}원';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 5 : 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? AppColors.navy : Colors.transparent,
            width: 2,
          ),
        ),
        child: SizedBox(
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: (item['ImageUrl'] != null &&
                            item['ImageUrl'].isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: item['ImageUrl'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                _buildPlaceholderItem(item))
                        : _buildPlaceholderItem(item),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['Name'] ?? '아이템 이름',
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.navy : Colors.black,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedPrice,
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedStyle} 스타일 추천'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (topItems.isEmpty || bottomItems.isEmpty)
              ? Center(child: Text('해당 스타일의 아이템이 없습니다.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '상의를 선택해주세요',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: topItems.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildItemCard(
                                      topItems[index],
                                      selectedTop == topItems[index],
                                      () => _selectTop(topItems[index])),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '하의를 선택해주세요',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: bottomItems.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildItemCard(
                                      bottomItems[index],
                                      selectedBottom == bottomItems[index],
                                      () => _selectBottom(bottomItems[index])),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _handleNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          '다음 단계',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

Widget _buildPlaceholderItem(Map<String, dynamic> item) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_not_supported,
          color: Colors.grey[500],
          size: 50,
        ),
        Text(
          item['Brand'] ?? '브랜드',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}

extension NumberFormat on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

// 서버에 데이터 전달
Future<Map<String, dynamic>> sendOutfitDataToServer({
  required String userId,
  required BuildContext context,
  required Map<String, dynamic> selectedTop,
  required Map<String, dynamic> selectedBottom,
  required String outfitName,
}) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  try {
    // Firestore에서 isProcessing 상태 확인
    final userDoc = await userRef.get();
    if (userDoc.data()?['isProcessing'] == true) {
      return {'error': '이미 처리 중인 요청이 있습니다. 잠시 후 다시 시도해주세요.'};
    }

    // FCM 토큰 가져오기
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      return {'error': '알림 토큰을 가져올 수 없습니다.'};
    }

    // Firestore에서 isProcessing 상태를 true로 설정
    await userRef.update({'isProcessing': true});

    final url = Uri.parse('http://172.18.8.232:8000/model');
    final data = {
      'userId': userId,
      'outfitName': outfitName,
      'fcmToken': fcmToken,
      'top': {
        'imageUrl': selectedTop['ImageUrl'] ?? '',
        'name': selectedTop['Name'] ?? '',
      },
      'bottom': {
        'imageUrl': selectedBottom['ImageUrl'] ?? '',
        'name': selectedBottom['Name'] ?? '',
      },
    };

    // 서버로 데이터 전송
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      await userRef.update({'isProcessing': false});
      return {'success': true, 'message': '데이터 전송 성공'};
    } else {
      await userRef.update({'isProcessing': false});
      return {'error': '데이터 전송 실패: ${response.statusCode}'};
    }
  } catch (e) {
    await userRef.update({'isProcessing': false});
    return {'error': '오류 발생: $e'};
  }
}
