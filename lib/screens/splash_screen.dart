import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';

import '../main.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  checkLogin(context) async {
    await Future.delayed(Duration(seconds: 1));
    var pref = await prefs;

    if (pref.getBool("loggedIn") == true) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false);
    }
  }
}
