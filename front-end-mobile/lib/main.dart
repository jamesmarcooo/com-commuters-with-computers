// @dart=2.9
import 'package:front_end_mobile/login/login.dart';
// import 'package:front_end_mobile/map/map.dart';
// import 'package:front_end_mobile/signup/signup.dart';
import 'package:front_end_mobile/homepage/homepage.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/login': (context) => Login(),
      //   '/register': (context) => Signup(),
      '/homepage': (context) => const HomePage(),
      //   '/livelocation': (context) => MapPage()
    },
    home: MyApp(),
  ));
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 4,
        navigateAfterSeconds: const HomePage(),
        // title: new Text(
        //   'Welcome to BusTracker',
        //   style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        // ),
        image: const Image(
          image: AssetImage('assets/images/com-02.png'),
          width: 300,
          height: 300,
        ),
        backgroundColor: const Color(0xff2a9d8f),
        styleTextUnderTheLoader: const TextStyle(),
        photoSize: 100.0,
        loaderColor: Colors.red);
  }
}
