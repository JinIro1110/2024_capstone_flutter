import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:intl/intl.dart';

class SocialUserInfoScreen extends StatefulWidget {
  final User user;

  SocialUserInfoScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SocialUserInfoScreenState createState() => _SocialUserInfoScreenState();
}

class _SocialUserInfoScreenState extends State<SocialUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = '남자';
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.user.phoneNumber ?? '';
    _nameController.text = widget.user.displayName ?? '';
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
      final storageRef = FirebaseStorage.instance.ref().child('users/$uid');
      await storageRef.child('.init').putString('initialized');

      final directories = ['images', 'models'];
      for (String dir in directories) {
        await storageRef.child('$dir/.init').putString('initialized');
      }
    } catch (e) {
      print('Storage initialization error: $e');
    }
  }

  Future<void> _saveUserInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .set({
          'email': widget.user.email,
          'phone': _phoneController.text.replaceAll('-', ''),
          'name': _nameController.text,
          'gender': _selectedGender,
          'birth': _birthController.text,
          'height': double.tryParse(_heightController.text) ?? 0.0,
          'storageInitialized': true,
        }, SetOptions(merge: true));
        
        await _initializeUserStorage(widget.user.uid);

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정보 저장에 실패했습니다. 오류: $e')),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.navy,
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
                      final formattedNumber = formatPhoneNumber(value);
                      _phoneController.value = TextEditingValue(
                        text: formattedNumber,
                        selection: TextSelection.collapsed(
                            offset: formattedNumber.length),
                      );
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
                    validator: _validateHeight,
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _saveUserInfo,
                    child: const Text('저장하기'),
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
    value = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (value.length == 10) {
      return '${value.substring(0, 3)}-${value.substring(3, 6)}-${value.substring(6)}';
    } else if (value.length == 11) {
      return '${value.substring(0, 3)}-${value.substring(3, 7)}-${value.substring(7)}';
    }
    return value;
  }
}