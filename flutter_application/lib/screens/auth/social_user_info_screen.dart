import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:intl/intl.dart';

class SocialUserInfoScreen extends StatefulWidget {
  final User user;

  // SocialUserInfoScreen 위젯 클래스 생성자
  SocialUserInfoScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SocialUserInfoScreenState createState() => _SocialUserInfoScreenState();
}

class _SocialUserInfoScreenState extends State<SocialUserInfoScreen> {
  final _formKey = GlobalKey<FormState>(); // 폼 검증 키 선언
  String _selectedGender = '남자'; // 선택된 성별 초기값 설정
  final _phoneController = TextEditingController(); // 전화번호 컨트롤러
  final _nameController = TextEditingController(); // 이름 컨트롤러
  final _birthController = TextEditingController(); // 생년월일 컨트롤러
  final _heightController = TextEditingController(); // 신장 컨트롤러

  @override
  void initState() {
    super.initState();
    // 화면 초기화 시 사용자 정보 설정
    _phoneController.text = widget.user.phoneNumber ?? '';
    _nameController.text = widget.user.displayName ?? '';
  }

  @override
  void dispose() {
    // 위젯 컨트롤러 메모리 해제
    _phoneController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // 사용자 스토리지를 초기화하는 메서드
  Future<void> _initializeUserStorage(String uid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('users/$uid');
      // 사용자 루트 디렉토리에 초기화 파일 저장
      await storageRef.child('.init').putString('initialized');

      final directories = ['images', 'models'];
      // 각 디렉토리 초기화 작업 수행
      for (String dir in directories) {
        await storageRef.child('$dir/.init').putString('initialized');
      }
    } catch (e) {
      // 오류 발생 시 출력
      print('Storage initialization error: $e');
    }
  }

  // 사용자 정보를 저장하는 메서드
  Future<void> _saveUserInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Firestore에 사용자 정보 저장
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .set({
          'email': widget.user.email,
          'phone': _phoneController.text.replaceAll('-', ''), // 전화번호 포맷 수정
          'name': _nameController.text,
          'gender': _selectedGender,
          'birth': _birthController.text,
          'height': double.tryParse(_heightController.text) ?? 0.0,
          'storageInitialized': true,
          'isProcessing': false,
        }, SetOptions(merge: true));

        // 사용자 스토리지를 초기화 메서드 호출
        await _initializeUserStorage(widget.user.uid);

        // 저장 완료 후 홈 화면으로 이동
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        // 저장 실패 시 에러 메시지 출력
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정보 저장에 실패했습니다. 오류: $e')),
        );
      }
    }
  }

  // 날짜 선택 메서드 - 생년월일 선택 팝업 표시
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // 선택한 날짜를 텍스트 필드에 설정
        _birthController.text = DateFormat('yyyyMMdd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 화면 상단 AppBar 설정
      appBar: AppBar(
        title: const Text('회원가입'), // 앱 바 제목 설정
        foregroundColor: Colors.white, // 제목 색상 설정
        backgroundColor: AppColors.navy, // 앱 바 배경 색상 설정
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0), // 전체 컨텐츠에 여백 추가
            child: Form(
              key: _formKey, // 폼 검증 키 설정
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 전화번호 입력 필드
                  _buildTextField(
                    controller: _phoneController,
                    labelText: '전화번호',
                    helperText: '전화번호를 입력해주세요.',
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      // 전화번호 포맷 변경 처리
                      final formattedNumber = formatPhoneNumber(value);
                      _phoneController.value = TextEditingValue(
                        text: formattedNumber,
                        selection: TextSelection.collapsed(
                            offset: formattedNumber.length),
                      );
                    },
                    validator: _validatePhone, // 전화번호 검증 메서드 호출
                  ),
                  const SizedBox(height: 20.0), // 위젯 간 여백 추가

                  // 이름과 성별 선택 필드를 나란히 배치
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _nameController,
                          labelText: '이름',
                          helperText: '이름을 입력해주세요.',
                          validator: _validateName, // 이름 검증 메서드 호출
                        ),
                      ),
                      const SizedBox(width: 20.0), // 필드 간 여백 설정
                      _buildGenderDropdown(), // 성별 선택 드롭다운 위젯 호출
                    ],
                  ),
                  const SizedBox(height: 20.0), // 여백 추가

                  // 생년월일 선택 필드
                  _buildDatePicker(),

                  const SizedBox(height: 20.0), // 여백 추가

                  // 신장 입력 필드
                  _buildTextField(
                    controller: _heightController,
                    labelText: '신장 (cm)',
                    helperText: '신장을 cm 단위로 입력해주세요',
                    keyboardType: TextInputType.number,
                    validator: _validateHeight, // 신장 검증 메서드 호출
                  ),
                  const SizedBox(height: 20.0), // 여백 추가

                  // 저장 버튼 위젯
                  ElevatedButton(
                    onPressed: _saveUserInfo, // 저장 버튼 클릭 이벤트
                    child: const Text('저장하기'),
                  ),
                  const SizedBox(height: 20.0), // 버튼 간 여백 설정
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// 텍스트 입력 필드를 생성하는 메서드
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String helperText,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator, // 입력값 검증 메서드 설정
      keyboardType: keyboardType, // 키보드 타입 설정 (예: 전화번호, 숫자 입력 등)
      onChanged: onChanged, // 값이 변경될 때 호출되는 콜백 함수
      decoration: InputDecoration(
        labelText: labelText, // 입력 필드의 레이블 텍스트 설정
        labelStyle:
            const TextStyle(fontSize: 18, color: Colors.grey), // 레이블 스타일 설정
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2), // 입력 필드 배경 색상 설정
        helperText: helperText, // 헬퍼 텍스트 표시
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // 테두리 반경 설정
          borderSide: BorderSide.none, // 테두리 색상 설정
        ),
      ),
    );
  }

// 성별 선택 드롭다운 위젯 생성 메서드
  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2), // 배경 색상 설정
        borderRadius: BorderRadius.circular(10.0), // 테두리 반경 설정
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender, // 선택된 성별 값 유지
          icon: Icon(Icons.arrow_drop_down,
              color: Theme.of(context).primaryColor), // 드롭다운 아이콘 색상 설정
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedGender = newValue; // 선택된 성별 값 업데이트
              });
            }
          },
          items: <String>['남자', '여자'] // 성별 옵션 설정
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

// 생년월일 선택 필드를 위한 위젯 메서드
  Widget _buildDatePicker() {
    return TextFormField(
      controller: _birthController,
      readOnly: true, // 입력 필드를 읽기 전용으로 설정
      onTap: () => _selectDate(context), // 선택 이벤트 처리
      decoration: InputDecoration(
        labelText: '생년월일', // 입력 필드 레이블 설정
        labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2), // 배경 색상 설정
        helperText: '생년월일을 선택해주세요', // 헬퍼 텍스트 설정
        suffixIcon: const Icon(Icons.calendar_today), // 달력 아이콘 추가
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: _validateBirth, // 생년월일 검증 메서드 설정
    );
  }

// 전화번호 검증 메서드
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    String numbers = value.replaceAll('-', '');
    if (!RegExp(r'^\d{10,11}$').hasMatch(numbers)) {
      return '올바른 전화번호 형식이 아닙니다.';
    }
    return null;
  }

// 이름 검증 메서드
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요.';
    }
    return null;
  }

// 생년월일 검증 메서드
  String? _validateBirth(String? value) {
    if (value == null || value.isEmpty) {
      return '생년월일을 선택해주세요.';
    }
    return null;
  }

// 신장 검증 메서드
  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return '신장을 입력해주세요.';
    }
    double? height = double.tryParse(value);
    if (height == null) {
      return '올바른 숫자를 입력해주세요.';
    }
    if (height < 50 || height > 250) {
      return '50cm에서 250cm 사이의 값을 입력해주세요.';
    }
    return null;
  }

// 전화번호 포맷팅 메서드
  String formatPhoneNumber(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (value.length == 10) {
      return '${value.substring(0, 3)}-${value.substring(3, 6)}-${value.substring(6)}';
    } else if (value.length == 11) {
      return '${value.substring(0, 3)}-${value.substring(3, 7)}-${value.substring(7)}';
    }
    return value;
  }
}
