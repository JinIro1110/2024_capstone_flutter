import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/services/closet_data.dart';
import 'package:flutter_application_1/utils/constants.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splash> {
  final _closetDataService = ClosetDataService();
  final bool _isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<Map<String, dynamic>> _preloadData(String userId) async {
    try {
      final result = await _closetDataService.loadInitialClosetData(userId);
      return result;
    } catch (e) {
      print('Data preloading error: $e');
      return {
        'items': [],
        'lastDocument': null,
        'error': e.toString(),
      };
    }
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Login())
      );
    } else {
      // Preload data before navigation
      final preloadedData = await _preloadData(user.uid);
      
      if (!mounted) return;

      // 데이터 로드 후 메인 화면으로 전환
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MyHomePage(
            preloadedItems: preloadedData['items'] ?? [],
            preloadedLastDocument: preloadedData['lastDocument'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppColors.navy,
                        AppColors.blue,
                        AppColors.white,
                      ],
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: const Text(
                      '입어봐',
                      style: TextStyle(
                        fontSize: 50.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const CircularProgressIndicator(), // 로딩 인디케이터 추가
                ],
              )
            : const SizedBox.shrink(), // 로딩이 끝나면 빈 공간을 반환
      ),
    );
  }
}
