import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'user_info_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth/sign_up_data.dart';

class SignUp1 extends StatefulWidget {
  final String? email;
  const SignUp1({super.key, this.email});

  @override
  _SignUp1Content createState() => _SignUp1Content();
}

class _SignUp1Content extends State<SignUp1> {
  final _formKey = GlobalKey<FormState>();  // 폼 유효성 검사를 위한 키
  final _emailController = TextEditingController();  // 이메일 입력 컨트롤러
  final _passwordController = TextEditingController();  // 비밀번호 입력 컨트롤러
  final _confirmPasswordController = TextEditingController();  // 비밀번호 확인 컨트롤러

  @override
  void initState() {
    super.initState();
    // 이메일 매개변수가 전달되었다면 컨트롤러에 값 설정
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  @override
  void dispose() {
    // 리소스 해제
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpData = Provider.of<SignUpData>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();  // 뒤로 가기 버튼 기능
          },
        ),
        title: const Text('회원가입'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,  // 폼 검사를 위한 키
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이메일 입력 필드 생성
                _buildTextField(
                  controller: _emailController,
                  labelText: '이메일',
                  helperText: '이메일을 입력해주세요.',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => signUpData.setEmail(value),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20.0),

                // 비밀번호 입력 필드 생성
                _buildTextField(
                  controller: _passwordController,
                  labelText: '비밀번호',
                  helperText: '비밀번호를 입력해주세요.',
                  obscureText: true,
                  onChanged: (value) => signUpData.setPassword(value),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20.0),

                // 비밀번호 확인 입력 필드 생성
                _buildTextField(
                  controller: _confirmPasswordController,
                  labelText: '비밀번호 확인',
                  helperText: '비밀번호를 재입력해주세요.',
                  obscureText: true,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 20.0),

                // 회원가입 버튼
                ElevatedButton(
                  onPressed: () => _submitForm(context, signUpData),
                  child: const Text('다음'),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 폼 제출 함수
  void _submitForm(BuildContext context, SignUpData signUpData) {
    if (_formKey.currentState!.validate()) {
      // 입력된 데이터를 SignUpData에 저장
      signUpData.setEmail(_emailController.text);
      signUpData.setPassword(_passwordController.text);

      // 다음 단계인 SignUp2 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignUp2(),
        ),
      );
    }
  }

  // 이메일 유효성 검사를 위한 함수
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    // 간단한 이메일 형식 검사
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return null;
  }

  // 비밀번호 유효성 검사를 위한 함수
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다.';
    }
    // 특수문자, 대문자, 숫자를 포함 여부 검토
    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) {
      return '비밀번호는 특수문자, 대문자, 숫자를 포함해야 합니다.';
    }
    return null;
  }

  // 비밀번호 확인 검사를 위한 함수
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 다시 입력해주세요.';
    }
    if (value != _passwordController.text) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return null;
  }

  // 텍스트 입력 필드를 빌드하는 함수
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String helperText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
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
}
