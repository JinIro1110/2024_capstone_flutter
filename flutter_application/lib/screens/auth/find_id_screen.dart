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

  Future<void> _findUserEmail() async {
    final name = _nameController.text;
    final phone = _phoneController.text;
    final birth = _birthController.text;

    final email = await AuthService().findUserEmail(name, phone, birth);
    setState(() {
      _foundEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('아이디 찾기'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock, size: 35.0),
                          SizedBox(height: 2.0),
                          Text('아이디를 잊어버리셨나요?',
                              style: TextStyle(fontSize: 22.0)),
                          SizedBox(height: 2.0),
                          Text('전화번호를 통해 아이디를 찾을 수 있어요.'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '이름',
                    labelStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
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
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: '전화번호',
                    labelStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    helperText: '전화번호를 입력해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _birthController,
                  decoration: InputDecoration(
                    labelText: '생년월일',
                    labelStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    helperText: '생년월일을 입력해주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _findUserEmail,
                  child: const Text('다음'),
                ),
                const SizedBox(height: 20.0),
                if (_foundEmail != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      const Text('회원님의 이메일 주소는:'),
                      Text(_foundEmail!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}