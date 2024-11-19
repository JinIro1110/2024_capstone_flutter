import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth/sign_up_data.dart';
import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SignUp2 extends StatefulWidget {
  const SignUp2({Key? key}) : super(key: key);

  @override
  _SignUp2State createState() => _SignUp2State();
}

class _SignUp2State extends State<SignUp2> {
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = '남자';
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _heightController = TextEditingController();
  late SignUpData signUpData;

  @override
  void initState() {
    super.initState();
    signUpData = Provider.of<SignUpData>(context, listen: false);
    // 이전 단계에서 필수 데이터가 없으면 뒤로 가기
    if (signUpData.email.isEmpty || signUpData.password.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserStorage(String uid) async {
    try {
      // 사용자의 기본 디렉토리 구조 생성
      final storageRef = FirebaseStorage.instance.ref().child('users/$uid');

      // 빈 텍스트 파일을 업로드하여 디렉토리 생성 (Firebase Storage는 빈 디렉토리를 허용하지 않음)
      await storageRef.child('.init').putString('initialized');

      // 하위 디렉토리들 생성
      final directories = ['images', 'models'];
      for (String dir in directories) {
        await storageRef.child('$dir/.init').putString('initialized');
      }
    } catch (e) {
      print('Storage initialization error: $e');
      // 스토리지 초기화 실패해도 회원가입은 계속 진행
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: signUpData.email,
          password: signUpData.password,
        );

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
        });

        await _initializeUserStorage(userCredential.user!.uid);

        // 회원가입 시 provider 객체 초기화
        signUpData.clearData();

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
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _phoneController,
                    labelText: '전화번호',
                    helperText: '전화번호를 입력해주세요.',
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      // 포맷된 전화번호를 컨트롤러에 설정
                      final formattedNumber = formatPhoneNumber(value);
                      _phoneController.value = TextEditingValue(
                        text: formattedNumber,
                        selection: TextSelection.collapsed(
                            offset: formattedNumber.length),
                      );
                      // Provider에는 하이픈을 제거한 숫자만 저장
                      signUpData.setPhone(formattedNumber.replaceAll('-', ''));
                    },
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 20.0),
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
                      _buildGenderDropdown(),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  _buildDatePicker(),
                  const SizedBox(height: 20.0),
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
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2),
        helperText: helperText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
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
              signUpData.setGender(newValue);
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

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _birthController,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: '생년월일',
        labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2),
        helperText: '생년월일을 선택해주세요',
        suffixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: _validateBirth,
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    // 하이픈을 제거하고 숫자만 검사
    String numbers = value.replaceAll('-', '');
    if (!RegExp(r'^\d{10,11}$').hasMatch(numbers)) {
      return '올바른 전화번호 형식이 아닙니다.';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요.';
    }
    return null;
  }

  String? _validateBirth(String? value) {
    if (value == null || value.isEmpty) {
      return '생년월일을 선택해주세요.';
    }
    return null;
  }

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

  String formatPhoneNumber(String value) {
    // 숫자만 추출
    value = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (value.length == 10) {
      return '${value.substring(0, 3)}-${value.substring(3, 6)}-${value.substring(6)}';
    } else if (value.length == 11) {
      return '${value.substring(0, 3)}-${value.substring(3, 7)}-${value.substring(7)}';
    }
    return value;
  }
}