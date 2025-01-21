import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/splash.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth/sign_up_data.dart';
import 'package:flutter_application_1/auth/login_logic.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create a global key for ScaffoldMessenger
    final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SignUpData()),
          ChangeNotifierProvider(create: (context) => LoginAuth()),
        ],
        child: MyApp(scaffoldMessengerKey: scaffoldMessengerKey),
      ),
    );

    // Since your current test seems to be for a counter app, but your actual app doesn't have a counter,
    // you'll need to modify these expectations to match your actual app's initial state.
    // For example, if you're starting with a Splash screen:
    expect(find.byType(Splash), findsOneWidget);
  });
}