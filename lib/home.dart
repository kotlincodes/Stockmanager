import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/items.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/purchase.dart';
import 'package:flutter_application_1/sales.dart';

/// This Widget is the main application widget.
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StateHome();
}

class _StateHome extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  var email = "";
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HOME PAGE'),
        backgroundColor: Color.fromARGB(201, 195, 114, 8),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      drawer: Drawer(
        elevation: 20.0,
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(""),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text("Profile"),
              ),
            ),
            Divider(
              height: 4,
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SalesScreen()));
              },
              title: Text("Sales"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PurchaseSreeen()));
              },
              title: Text("Purchase"),
            ),
            ListTile(
              title: Text("Report"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Items()));
              },
              title: Text("Items"),
            ),
          ],
        ),
      ),
    );
  }

  getUserDetails() async {
    var pref = await prefs;
    email = pref.getString("email") ?? "";
    uid = pref.getString("uid") ?? "";
    setState(() {});
  }
}
