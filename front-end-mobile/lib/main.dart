// @dart=2.9
import 'package:front_end_mobile/login/login.dart';
// import 'package:front_end_mobile/map/map.dart';
// import 'package:front_end_mobile/signup/signup.dart';
import 'package:front_end_mobile/homepage/homepage.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/login': (context) => Login(),
      //   '/register': (context) => Signup(),
      '/homepage': (context) => HomePage(),
      //   '/livelocation': (context) => MapPage()
    },
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 1,
        navigateAfterSeconds: new HomePage(),
        title: new Text(
          'Welcome to BusTracker',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        // image: new Image.network('https://i.imgur.com/TyCSG9A.png'),
        backgroundColor: Color(0xff2a9d8f),
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        loaderColor: Colors.red);
  }
}
