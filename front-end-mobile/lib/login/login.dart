import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:front_end_mobile/projectConfig.dart' as config;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  late String token;

  void verifylogin(String email, String pass) async {
    var jsondata = jsonEncode({
      "email": email,
      "password": pass,
    });

    var response = await http.post(
      Uri.http(config.BaseUrl, "user/login/"),
      body: jsondata,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final data = jsonDecode(response.body);

    print(data);
    if (data['status'] == 1) {
      Navigator.pushNamed(context, '/homepage');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("Refreshtoken", data['refresh']);
      prefs.setString("Accesstoken", data['access']);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green[300],
        content: const Text(
          "Loged in Successfully..!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red[300],
        content: const Text(
          "Invalid username & Password!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Container(
            padding: EdgeInsets.only(top: 40, left: 30, right: 20),
            child: Form(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back..!",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pasifico-Regular',
                              fontSize: 30),
                        ),
                      ],
                    ),

                    Image(
                      image: AssetImage('assets/images/log3.png'),
                      width: 300,
                      height: 300,
                    ),

                    Material(
                      elevation: 5,
                      shadowColor: Colors.grey,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "This field is Required";
                          }
                          return null;
                        },
                        controller: _emailController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          prefixIcon:
                              Icon(Icons.person, size: 20, color: Colors.black),
                          border: InputBorder.none,
                          fillColor: Colors.white,
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: 'Enter Your email',
                          labelText: 'Email',
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      height: 20.0,
                    ),
                    Material(
                      elevation: 5,
                      shadowColor: Colors.grey,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "This field is Required";
                          }
                          return null;
                        },
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          prefixIcon: Icon(
                            Icons.lock,
                            size: 20,
                            color: Colors.black,
                          ),
                          border: InputBorder.none,
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'password',
                          hintStyle: TextStyle(color: Colors.grey),
                          labelText: 'password',
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "forgot password?",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    SizedBox(height: 25),
                    // _submitButton(),
                    MaterialButton(
                      child: Text('Login'),
                      onPressed: () {
                        String email = _emailController.text;
                        String pass = _passwordController.text;
                        verifylogin(email, pass);
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Divider(
                      color: Colors.black,
                      height: 40,
                    )
                  ],
                ),
              ),
            )));
  }
}
