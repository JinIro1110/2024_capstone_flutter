import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import '../find/find_id.dart';
import '../find/find_password.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import '../../main_screen.dart';
import 'package:flutter_application_1/screens/auth_screen/sign_up/sign_up_1.dart';

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<LoginAuth>().signIn(
              _emailController.text.trim(),
              _passwordController.text,
            );
        // 로그인 성공 후 처리 (예: 홈 화면으로 이동)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } catch (error) {
        _showErrorDialog('로그인 실패', '이메일과 비밀번호를 확인하고 다시 시도해주세요.');
      }
    }
  }

  Future<void> _signUpWithEmail() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUp1()),
    );
  }

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
                _buildLogo(),
                const SizedBox(height: 50.0),
                _buildEmailField(),
                const SizedBox(height: 20.0),
                _buildPasswordField(),
                const SizedBox(height: 20.0),
                _buildLoginButton(),
                const SizedBox(height: 20.0),
                _buildSocialLoginButtons(),
                const SizedBox(height: 40.0),
                _buildFindCredentialsButtons(),
                const SizedBox(height: 20.0),
                _buildSignUpButton(),
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
          Color.fromARGB(224, 86, 98, 112),
          Color.fromARGB(224, 165, 147, 224),
          Color.fromARGB(224, 224, 227, 218),
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

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: '이메일',
        labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '이메일을 입력해주세요.';
        }
        if (!value.contains('@')) {
          return '유효한 이메일 주소를 입력해주세요.';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: '비밀번호',
        labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 입력해주세요.';
        }
        if (value.length < 6) {
          return '비밀번호는 6자 이상이어야 합니다.';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _loginWithEmail,
      child: const Text('로그인'),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialLoginButton(
          'assets/images/google.png',
          () async {
            UserCredential? result = await AuthService().signInWithGoogle();
            if (result != null) {
              String email = FirebaseAuth.instance.currentUser!.email!;
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => SignUp1(email: email),
                  builder: (context) => const SignUp1(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Google sign in failed')));
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

  Widget _buildFindCredentialsButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => FindId())),
          child: const Text('아이디 찾기'),
        ),
        TextButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => FindPassword())),
          child: const Text('비밀번호 찾기'),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return TextButton(
      onPressed: _signUpWithEmail,
      child: const Text('계정이 없다면?'),
    );
  }
}
