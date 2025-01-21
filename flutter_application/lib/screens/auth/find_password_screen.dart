import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class FindPassword extends StatefulWidget {
  const FindPassword({super.key});

  @override
  _FindPasswordState createState() => _FindPasswordState();
}

class _FindPasswordState extends State<FindPassword> {
  final _emailController = TextEditingController(); // 이메일 입력 컨트롤러
  final _nameController = TextEditingController();  // 이름 입력 컨트롤러
  final _birthController = TextEditingController();  // 생년월일 입력 컨트롤러

  // 비밀번호 재설정 이메일 전송 함수
  Future<void> _findUserPassword() async {
    final email = _emailController.text;
    final name = _nameController.text;
    final birth = _birthController.text;

    // AuthService 메서드를 호출하여 비밀번호 재설정을 위한 이메일 전송
    final success = await AuthService().findUserPassword(email, name, birth);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호 재설정 이메일이 전송되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // 뒤로 가기 버튼
          },
        ),
        title: const Text('비밀번호 찾기'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20.0),
                const Icon(Icons.lock_reset, size: 35.0), // 비밀번호 아이콘
                const SizedBox(height: 10.0),
                
                // 제목 텍스트
                const Text(
                  '비밀번호를 잊어버리셨나요?',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5.0),
                const Text('이메일로 비밀번호 재설정 링크를 보내드립니다.'),

                const SizedBox(height: 30.0),

                // 이메일 입력 필드
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    helperText: '이메일을 입력해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20.0),

                // 이름 입력 필드
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '이름',
                    labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    helperText: '이름을 입력해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),

                // 생년월일 입력 필드
                TextField(
                  controller: _birthController,
                  decoration: InputDecoration(
                    labelText: '생년월일',
                    labelStyle: const TextStyle(fontSize: 18, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    helperText: '생년월일을 입력해주세요 (예: 1990-01-01)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30.0),

                // 비밀번호 재설정 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _findUserPassword,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Text('비밀번호 재설정 이메일 보내기', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
