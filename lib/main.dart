import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:miniproject/sales.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  checkLogin() async {
    var pref = await prefs;

    if (pref.getBool("loggedIn") == true) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  void showToast(String s, Color c) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: c,
        textColor: Colors.white);
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(
            //   width: width,
            //   height: height * 0.45,
            //   child: Image.asset(
            //     'images/background.jpg',
            //     fit: BoxFit.fill,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Login',
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                suffixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: Icon(Icons.visibility_off),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Forget password?',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  MaterialButton(
                    child: Text('Login'),
                    color: Color(0xffEE7B23),
                    onPressed: () async {
                      // print(_emailController.toString() +
                      //     " " +
                      //     _passwordController.toString());
                      setState(() async {
                        try {
                          await _firebaseAuth
                              .signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text)
                              .then((value) async {
                            if (value.user != null) {
                              var pref = await prefs;
                              pref.setBool("loggedIn", true);
                              pref.setString("uid", value.user!.uid);
                              pref.setString("email", value.user!.email ?? "");
                            }

                            print('Login Successful');
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        } catch (e) {
                          String error;
                          error = e.toString();
                          int kpp = error.lastIndexOf(']') + 1;
                          showToast(
                              '${error.substring(kpp)}', Colors.red[300]!);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Second()));
              },
              child: Text.rich(
                TextSpan(text: 'Don\'t have an account', children: [
                  TextSpan(
                    text: 'Signup',
                    style: TextStyle(color: Color(0xffEE7B23)),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Second extends StatefulWidget {
  @override
  _SecondState createState() => _SecondState();
}

class _SecondState extends State<Second> {
  @override
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _username = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: width,
                height: height * 0.45,
                child: Image.asset(
                  'images/background.jpg',
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Signup',
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  suffixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: Icon(Icons.visibility_off),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              TextField(
                controller: _username,
                decoration: InputDecoration(
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Forget password?',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    MaterialButton(
                      child: Text('Signup'),
                      color: Color(0xffEE7B23),
                      onPressed: () async {
                        await _firebaseAuth.createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text);
                        users
                            .add({
                              'Email_Id': _emailController.text,
                              'Password': _passwordController.text,
                              'username': _username
                            })
                            .then((value) => print("User Added"))
                            .catchError(
                                (error) => print("Failed to add user: $error"));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyApp()));
                },
                child: Text.rich(
                  TextSpan(text: 'Already have an account', children: [
                    TextSpan(
                      text: 'Signin',
                      style: TextStyle(color: Color(0xffEE7B23)),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
var uid = "";
