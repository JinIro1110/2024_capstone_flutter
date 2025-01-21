import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class FindId extends StatefulWidget {
  const FindId({super.key});

  @override
  _FindIdState createState() => _FindIdState();
}

class _FindIdState extends State<FindId> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  String? _foundEmail;

  // 아이디 찾기 메서드
  Future<void> _findUserEmail() async {
    final name = _nameController.text;
    final phone = _phoneController.text;
    final birth = _birthController.text;

    try {
      // AuthService에서 이메일 찾는 메서드 호출
      final email = await AuthService().findUserEmail(name, phone, birth);
      setState(() {
        _foundEmail = email;
      });
    } catch (error) {
      // 에러 처리
      setState(() {
        _foundEmail = null;
      });
      _showErrorDialog('아이디 찾기 실패', '정보를 확인해주세요.');
    }
  }

  // 에러 다이얼로그 메서드
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('아이디 찾기'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.lock, size: 35.0),
              const SizedBox(height: 10.0),
              const Text('아이디를 잊어버리셨나요?', style: TextStyle(fontSize: 22.0)),
              const Text('전화번호와 생년월일로 아이디를 찾을 수 있습니다.'),

              const SizedBox(height: 20.0),

              // 이름 입력 필드
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // 전화번호 입력 필드
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
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
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              // 다음 버튼 클릭 시 아이디 찾기 메서드 실행
              ElevatedButton(
                onPressed: _findUserEmail,
                child: const Text('다음'),
              ),

              const SizedBox(height: 20.0),

              // 결과 이메일 출력
              if (_foundEmail != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('회원님의 이메일 주소:'),
                    Text(
                      _foundEmail!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
