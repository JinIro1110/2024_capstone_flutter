import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:flutter_application_1/widgets/alert.dart';
import 'find_id_screen.dart';
import 'find_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import '../main_screen.dart';
import 'package:flutter_application_1/screens/auth/email_singup_screen.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // 컨트롤러 메모리 해제
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 이메일 로그인 메서드
  Future<void> _loginWithEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<LoginAuth>().signIn(
              _emailController.text.trim(),
              _passwordController.text,
            );
        // 로그인 성공 후 홈 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } catch (error) {
        // 로그인 실패 시 에러 다이얼로그 표시
        _showErrorDialog('로그인 실패', '이메일과 비밀번호을 확인해주세요.');
      }
    }
  }

  // 이메일 회원가입 화면으로 이동
  Future<void> _signUpWithEmail() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUp1()),
    );
  }

  // 에러 다이얼로그 표시 메서드
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80.0),
                _buildLogo(),     // 앱 로고 표시
                const SizedBox(height: 50.0),
                _buildEmailField(),   // 이메일 입력 필드
                const SizedBox(height: 20.0),
                _buildPasswordField(), // 비밀번호 입력 필드
                const SizedBox(height: 20.0),
                _buildLoginButton(),    // 로그인 버튼 UI
                const SizedBox(height: 20.0),
                _buildSocialLoginButtons(),   // 소셜 로그인 버튼
                const SizedBox(height: 40.0),
                _buildFindCredentialsButtons(), // 아이디/비밀번호 찾기 버튼
                const SizedBox(height: 20.0),
                _buildSignUpButton(),  // 회원가입 버튼 UI
                const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          AppColors.navy,
          AppColors.blue,
          AppColors.lavender,
        ],
      ).createShader(bounds),
      child: const Text(
        '입어봐',
        style: TextStyle(
          fontSize: 50.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // 이메일 입력 필드
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: '이메일',
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
        if (!value.contains('@')) return '유효한 이메일 주소를 입력해주세요.';
        return null;
      },
    );
  }

  // 비밀번호 입력 필드
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: '비밀번호',
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '비밀번호을 입력해주세요.';
        if (value.length < 6) return '비밀번호는 최소 6자 이상이어야 합니다.';
        return null;
      },
    );
  }

  // 로그인 버튼 UI
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _loginWithEmail,
      child: const Text('로그인'),
    );
  }

  // 소셜 로그인 버튼 UI
  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialLoginButton(
          'assets/images/google.png',
          () async {
            try {
              await AuthService().googleSocialLogin(context);
            } catch (error) {
              _showErrorDialog('Google 로그인 실패', error.toString());
            }
          },
        ),
      ],
    );
  }

  Widget _socialLoginButton(String assetName, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Image.asset(assetName, width: 24, height: 24),
    );
  }

  // 아이디 찾기/비밀번호 찾기 버튼
  Widget _buildFindCredentialsButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const FindId())),
          child: const Text('아이디 찾기'),
        ),
        TextButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const FindPassword())),
          child: const Text('비밀번호 찾기'),
        ),
      ],
    );
  }

  // 계정이 없는 경우 회원가입 버튼
  Widget _buildSignUpButton() {
    return TextButton(
      onPressed: _signUpWithEmail,
      child: const Text('계정이 없다면?'),
    );
  }
}
