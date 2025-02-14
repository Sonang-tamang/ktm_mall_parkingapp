import 'package:flutter/material.dart';
import 'package:pakingapp/authentication/Login.dart';
import 'package:pakingapp/homepage.dart';
import 'package:pakingapp/authentication/Login.dart';
import 'package:pakingapp/homepage.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getString('token') != null;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? Homepage() : Login(),
    );
  }
}
