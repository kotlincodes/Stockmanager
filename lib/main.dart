import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/splash_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:miniproject/sales.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
        // Define the default brightness and colors.
        primaryColor: Colors.deepPurple,

        // Define the default font family.
        fontFamily: 'Georgia',
        appBarTheme: AppBarTheme(
          color: Colors.teal,
        )),
    home: SplashScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
var uid = "";
var dateFormatter = DateFormat('dd-MM-yyyy');
