import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/purchase.dart';
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
  bool isLoading = false;
  CollectionReference itms = FirebaseFirestore.instance.collection("users");
  @override
  void initState() {
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
              isLoading == true
                  ? CircularProgressIndicator(
                      semanticsLabel: "Loading...",
                    )
                  : MaterialButton(
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
                          showProgressbar();

                          itms
                              .doc(uid)
                              .collection("items")
                              .where('name', isEqualTo: _itemname.text)
                              .get()
                              .then((value) {
                            if (value.docs.isEmpty) {
                              itms.doc(uid).collection("items").doc().set({
                                'name': _itemname.text,
                                'description': _description.text,
                                "qty": 0,
                                "purchase_price": 0
                              });
                              hideProgress();
                              Navigator.pop(context);
                            } else {
                              hideProgress();
                              showToast("Item Already exists");
                            }
                          });
                        } catch (e) {
                          hideProgress();
                          showToast(
                              "Something went wrong, Please try again later");
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

  showProgressbar() {
    isLoading = true;
    setState(() {});
  }

  hideProgress() {
    isLoading = false;
    setState(() {});
  }

  getItems() {
    itms.doc(uid).collection("Items").get().then((value) {
      print(value);
    });
  }
}
