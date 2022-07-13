import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/styles.dart';

class Items extends StatefulWidget {
  const Items({super.key});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  @override
  final TextEditingController _itemname = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _qty = TextEditingController();
  CollectionReference itms = FirebaseFirestore.instance.collection("users");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                  controller: _itemname,
                  style: inputstyle(),
                  decoration: inputdec("Name*", Icons.food_bank)),
              SizedBox(
                height: 20,
              ),
              TextField(
                  controller: _description,
                  style: inputstyle(),
                  decoration:
                      inputdec("Description*", Icons.description_outlined)),
              SizedBox(
                height: 20,
              ),
              // TextField(
              //     keyboardType: TextInputType.numberWithOptions(
              //         signed: true, decimal: false),
              //     controller: _qty,
              //     style: inputstyle(),
              //     decoration:
              //         inputdec("Qty*", Icons.shopping_cart_checkout_outlined)),
              // SizedBox(
              //   height: 20,
              // ),
              MaterialButton(
                disabledColor: Colors.grey[300],
                color: Colors.cyan, //Color(0xffff2d55),
                elevation: 0,
                // minWidth: 400,
                height: 50,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'SFUIDisplay',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  try {
                    itms.doc(uid).collection("Items").doc().set({
                      'Name': _itemname.text,
                      'Description': _description.text,
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    print(e);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  getItems() {
    itms.doc(uid).collection("Items").get().then((value) {
      print(value);
    });
  }
}
