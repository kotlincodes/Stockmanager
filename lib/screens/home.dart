import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/items.dart';
import 'package:flutter_application_1/screens/purchase.dart';
import 'package:flutter_application_1/screens/report_screen.dart';
import 'package:flutter_application_1/screens/sales.dart';

import '../model/item_model.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StateHome();
}

class _StateHome extends State<HomePage> {
  final List<ItemsModel> listItem = [];
  CollectionReference itms = FirebaseFirestore.instance.collection("users");
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
      ),
      body: ListView.builder(
          itemCount: listItem.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(listItem[index].name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Stock: ${listItem[index].qty}"),
                    Text("Purchase Price: ${listItem[index].purchasePrice}"),
                    Text("Sales Price: ${listItem[index].salesPrice}"),
                  ],
                ),
              ),
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      drawer: Drawer(
        elevation: 20.0,
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
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
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ReportScreen()));
              },
              title: Text("Report"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Items()));
              },
              title: Text("Items"),
            ),
            ListTile(
              onTap: () {
                logOut();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              trailing: Icon(Icons.exit_to_app),
              title: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }

  logOut() async {
    var pref = await prefs;

    pref.setBool("loggedIn", false);
    pref.clear();
  }

  getUserDetails() async {
    var pref = await prefs;
    email = pref.getString("email") ?? "";
    uid = pref.getString("uid") ?? "";
    getItems();
    setState(() {});
  }

  getItems() {
    itms
        .doc(uid)
        .collection("items")
        .snapshots(includeMetadataChanges: true)
        .listen((event) {
      listItem.clear();
      for (var element in event.docs) {
        ItemsModel itemsModel = ItemsModel();
        print(element.data().toString());
        itemsModel.name = element.data()["name"].toString().toUpperCase();
        itemsModel.description = element.data()["description"];
        itemsModel.purchasePrice = element.data()['purchase_price'];
        itemsModel.salesPrice = element.data()['sales_price'];
        itemsModel.qty = element.data()['qty'];
        itemsModel.docId = element.id;
        listItem.add(itemsModel);
      }
      listItem.sort((a, b) => b.purchasePrice.compareTo(a.purchasePrice));
      setState(() {});
    });
  }
}
