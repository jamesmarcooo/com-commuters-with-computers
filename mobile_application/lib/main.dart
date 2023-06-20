//@dart=2.9
import 'package:mobile_application/pages/home/home.dart';
import 'package:mobile_application/pages/onboarding/onboarding.dart';
import 'package:mobile_application/repositories/user_repository.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    UserRepository.instance.signInCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Cab',
      theme: ComTheme.theme,
      home: SplashScreen(
          seconds: 2,
          navigateAfterSeconds: const HomePage(),
          image: const Image(
            image: AssetImage('assets/images/com-02.png'),
          ),
          backgroundColor: const Color(0xff5644B2),
          styleTextUnderTheLoader: const TextStyle(),
          photoSize: 140.0,
          loaderColor: const Color(0xff2A2563)),
    );
  }
}
