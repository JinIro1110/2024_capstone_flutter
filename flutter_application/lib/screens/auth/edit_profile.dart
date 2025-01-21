import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;  // Firebase 인증 인스턴스 생성
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  // Firestore 인스턴스 생성
  Map<String, dynamic>? userData;  // 사용자 데이터 저장
  bool isLoading = true;  // 데이터 로딩 상태

  @override
  void initState() {
    super.initState();
    _loadUserData();  // 프로필 데이터 로드
  }

  // 사용자 데이터 로드 함수
  Future<void> _loadUserData() async {
    try {
      final User? currentUser = _auth.currentUser;  // 현재 로그인한 사용자 정보 가져오기
      if (currentUser != null) {
        final DocumentSnapshot doc =
            await _firestore.collection('users').doc(currentUser.uid).get();  // Firestore에서 사용자 데이터 가져오기
        if (doc.exists) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');  // 오류 처리
      setState(() {
        isLoading = false;
      });
    }
  }

  // 사용자 정보를 화면에 표시하는 위젋 빌더 함수
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 아이콘 표시 영역
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // 사용자 정보 레이블과 값 표시
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // 데이터 로딩 중일 때 프로그레스 인디케이터 표시
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.blue,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        title: const Text(
          '프로필 정보',  // 앱 바 제목 설정
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),  // 뒤로가기 버튼 기능
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 프로필 영역 (배경 색상 설정)
            Container(
              width: double.infinity,
              color: AppColors.blue,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData?['name'] ?? '',  // 사용자 이름 표시
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // 사용자 정보를 나열하는 부분
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoItem('이메일', userData?['email'] ?? '', Icons.email),
                  _buildInfoItem(
                    '생년월일',
                    userData?['birth']?.toString().replaceAllMapped(
                            RegExp(r'(\d{4})(\d{2})(\d{2})'),
                            (Match m) => '${m[1]}년 ${m[2]}월 ${m[3]}일') ??
                        '',
                    Icons.calendar_today,
                  ),
                  _buildInfoItem('성별', userData?['gender'] ?? '', Icons.person_outline),
                  _buildInfoItem('키', '${userData?['height'] ?? ''}cm', Icons.height),
                  _buildInfoItem(
                    '전화번호',
                    userData?['phone']?.toString().replaceAllMapped(
                              RegExp(r'(\d{3})(\d{4})(\d{4})'),
                              (Match m) => '${m[1]}-${m[2]}-${m[3]}',
                            ) ??
                        '',
                    Icons.phone,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
