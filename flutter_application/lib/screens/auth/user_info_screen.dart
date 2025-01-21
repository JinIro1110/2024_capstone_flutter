import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth/sign_up_data.dart';
import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 회원가입 화면 2단계 (SignUp2)
class SignUp2 extends StatefulWidget {
  const SignUp2({Key? key}) : super(key: key);

  @override
  _SignUp2State createState() => _SignUp2State();
}

class _SignUp2State extends State<SignUp2> {
  final _formKey = GlobalKey<FormState>(); // 폼 검증을 위한 키
  String _selectedGender = '남자'; // 선택한 성별 초기 값
  final _phoneController = TextEditingController(); // 전화번호 컨트롤러
  final _nameController = TextEditingController(); // 이름 컨트롤러
  final _birthController = TextEditingController(); // 생년월일 컨트롤러
  final _heightController = TextEditingController(); // 신장 컨트롤러
  late SignUpData signUpData; // SignUpData 프로바이더 데이터 객체

  @override
  void initState() {
    super.initState();
    signUpData = Provider.of<SignUpData>(context, listen: false);

    // 이전 단계에서 필수 데이터(email, password)가 없으면 뒤로 가기 처리
    if (signUpData.email.isEmpty || signUpData.password.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    // 컨트롤러 메모리 누수를 방지하기 위해 dispose 처리
    _phoneController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // Firebase Storage 초기화 메서드
  Future<void> _initializeUserStorage(String uid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('users/$uid');

      // 빈 텍스트 파일을 업로드하여 디렉토리 생성 (빈 디렉토리는 Firebase Storage에서 허용하지 않음)
      await storageRef.child('.init').putString('initialized');

      // 하위 디렉토리 생성 (이미지 및 모델 저장소 생성)
      final directories = ['images', 'models'];
      for (String dir in directories) {
        await storageRef.child('$dir/.init').putString('initialized');
      }
    } catch (e) {
      print('Storage initialization error: $e');
      // 스토리지 초기화 실패해도 회원가입 프로세스를 계속 진행합니다.
    }
  }

  // 사용자 회원가입 등록 메서드
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Firebase Authentication을 사용하여 사용자 계정 생성
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: signUpData.email,
          password: signUpData.password,
        );

        // Firestore에 사용자 정보를 저장
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
          "email": signUpData.email,
          "phone": signUpData.phone,
          "name": signUpData.name,
          "gender": signUpData.gender,
          "birth": signUpData.birth,
          "height": signUpData.height,
          "storageInitialized": true,
          "isProcessing": false,
        });

        // 사용자 Storage 초기화 메서드 호출
        await _initializeUserStorage(userCredential.user!.uid);

        // SignUpData 프로바이더 데이터 초기화
        signUpData.clearData();

        // 회원가입 완료 후 로그인 페이지로 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = '회원가입에 실패했습니다.';
        if (e.code == 'weak-password') {
          errorMessage = '비밀번호가 너무 약합니다.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = '이미 사용 중인 이메일입니다.';
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  // 달력 팝업으로 생년월일 선택 메서드
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthController.text = DateFormat('yyyyMMdd').format(picked);
      });
      signUpData.setBirth(_birthController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar 설정: 상단 앱 바
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 뒤로 가기 버튼 눌렀을 때 데이터 초기화
            Provider.of<SignUpData>(context, listen: false).clearData();
            Navigator.of(context).pop();
          },
        ),
        title: const Text('회원가입'),
        backgroundColor: AppColors.navy, // 앱 바 배경 색상 설정
        foregroundColor: Colors.white, // 앱 바 글자 색상 설정
      ),

      // 페이지 컨텐츠를 위한 본문 영역
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
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
                      // 입력값이 변경될 때마다 전화번호 포맷 처리
                      final formattedNumber = formatPhoneNumber(value);
                      _phoneController.value = TextEditingValue(
                        text: formattedNumber,
                        selection: TextSelection.collapsed(
                            offset: formattedNumber.length),
                      );
                      // Provider에 하이픈 제거된 숫자 저장
                      signUpData.setPhone(formattedNumber.replaceAll('-', ''));
                    },
                    validator: _validatePhone,
                  ),

                  const SizedBox(height: 20.0),

                  // 이름 입력 필드 및 성별 선택 드롭다운을 나란히 배치
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _nameController,
                          labelText: '이름',
                          helperText: '이름을 입력해주세요.',
                          onChanged: (value) => signUpData.setName(value),
                          validator: _validateName,
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      _buildGenderDropdown(), // 성별 선택 드롭다운
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  // 생년월일 선택 필드 달력
                  _buildDatePicker(),

                  const SizedBox(height: 20.0),

                  // 신장 입력 필드
                  _buildTextField(
                    controller: _heightController,
                    labelText: '신장 (cm)',
                    helperText: '신장을 cm 단위로 입력해주세요',
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        signUpData.setHeight(double.tryParse(value) ?? 0.0),
                    validator: _validateHeight,
                  ),

                  const SizedBox(height: 20.0),

                  // 회원가입 완료 버튼
                  ElevatedButton(
                    onPressed: _registerUser,
                    child: const Text('회원가입 완료'),
                  ),

                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// 입력 필드를 생성하는 메서드
// controller: 입력 컨트롤러, labelText: 라벨 텍스트, helperText: 헬퍼 텍스트
// keyboardType: 키보드 타입 설정, onChanged: 입력값 변경 이벤트 처리, validator: 입력 검증 로직
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
      validator: validator,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText, // 입력 필드 상단 라벨 설정
        labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2), // 입력 필드 배경 색상 설정
        helperText: helperText, // 입력 필드 도움말 텍스트 설정
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // 테두리 둥글기 설정
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

// 성별 선택 드롭다운 생성 메서드
  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2), // 드롭다운 배경 색상 설정
        borderRadius: BorderRadius.circular(10.0), // 드롭다운 테두리 둥글기 설정
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender, // 선택된 성별 값 저장
          icon: Icon(Icons.arrow_drop_down,
              color: Theme.of(context).primaryColor),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedGender = newValue;
              });
              signUpData.setGender(newValue); // 선택한 성별 데이터를 저장
            }
          },
          items: <String>['남자', '여자']
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

// 생년월일 선택 필드를 위한 위젯 생성 메서드
  Widget _buildDatePicker() {
    return TextFormField(
      controller: _birthController,
      readOnly: true, // 입력 필드를 읽기 전용으로 설정
      onTap: () => _selectDate(context), // 달력 선택 이벤트 처리
      decoration: InputDecoration(
        labelText: '생년월일',
        labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2),
        helperText: '생년월일을 선택해주세요',
        suffixIcon: const Icon(Icons.calendar_today), // 달력 아이콘 추가
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: _validateBirth, // 입력 검증 로직 적용
    );
  }

// 전화번호 입력 검증 메서드
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    String numbers = value.replaceAll('-', ''); // 하이픈 제거
    if (!RegExp(r'^\d{10,11}$').hasMatch(numbers)) {
      return '올바른 전화번호 형식이 아닙니다.'; // 전화번호 형식 검증
    }
    return null;
  }

// 이름 입력 검증 메서드
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요.';
    }
    return null;
  }

// 생년월일 입력 검증 메서드
  String? _validateBirth(String? value) {
    if (value == null || value.isEmpty) {
      return '생년월일을 선택해주세요.';
    }
    return null;
  }

// 신장 입력 검증 메서드
  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return '신장을 입력해주세요.';
    }
    double? height = double.tryParse(value);
    if (height == null) {
      return '올바른 숫자를 입력해주세요.';
    }
    if (height < 50 || height > 250) {
      return '50cm에서 250cm 사이의 값을 입력해주세요.'; // 신장 범위 검증
    }
    return null;
  }

// 전화번호 포맷팅 메서드
  String formatPhoneNumber(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), ''); // 숫자만 추출

    if (value.length == 10) {
      return '${value.substring(0, 3)}-${value.substring(3, 6)}-${value.substring(6)}';
    } else if (value.length == 11) {
      return '${value.substring(0, 3)}-${value.substring(3, 7)}-${value.substring(7)}';
    }
    return value;
  }
}
