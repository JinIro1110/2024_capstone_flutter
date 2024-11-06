import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/screens/splash.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1/auth/sign_up_data.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SignUpData()),
        ChangeNotifierProvider(create: (context) => LoginAuth()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '입어봐',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Splash(),
      routes: routes,
    );
  }
}