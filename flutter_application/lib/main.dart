import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/screens/splash.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1/auth/sign_up_data.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// 앱의 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 프레임워크 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 초기화
  );
  
  // Firebase App Check 활성화 (Android 디버그 모드)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // ScaffoldMessenger의 전역 키 생성
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // MultiProvider를 사용하여 상태 관리 객체 제공
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SignUpData()), // 회원가입 데이터 관리
        ChangeNotifierProvider(create: (context) => LoginAuth()), // 로그인 인증 관리
      ],
      child: MyApp(scaffoldMessengerKey: scaffoldMessengerKey),
    ),
  );
}

/// 앱의 루트 위젯
class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const MyApp({Key? key, required this.scaffoldMessengerKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Firebase 메시지 수신 이벤트 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // 메시지가 존재하면 스낵바를 통해 사용자에게 알림
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(message.notification?.body ?? '알림'), // 알림 내용 표시
            backgroundColor: Colors.black, // 스낵바 배경색
          ),
        );
      }
    });

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey, // 전역 ScaffoldMessenger 사용
      title: '입어봐', // 앱 제목
      theme: ThemeData(
        primarySwatch: Colors.blue, // 앱의 기본 테마 색상
      ),
      home: const Splash(), // 초기 화면(Splash 화면)
      routes: routes, // 정의된 라우트 테이블
    );
  }
}
