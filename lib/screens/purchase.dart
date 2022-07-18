import 'dart:math';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/model/item_model.dart';
import 'package:flutter_application_1/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PurchaseSreeen extends StatefulWidget {
  const PurchaseSreeen({super.key});

  @override
  State<PurchaseSreeen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseSreeen> {
  final List<ItemsModel> listItem = [];
  final TextEditingController _itemname = TextEditingController();
  final TextEditingController _purchasePrice = TextEditingController();
  final TextEditingController _salesPrice = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _qty = TextEditingController();
  CollectionReference itms = FirebaseFirestore.instance.collection("users");
  GlobalKey<AutoCompleteTextFieldState<ItemsModel>> key =
      GlobalKey<AutoCompleteTextFieldState<ItemsModel>>();
  ItemsModel? selectedItem;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Purchase"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InputDecorator(
                decoration: inputdec(
                    "Item Name *", Icons.shopping_cart_checkout_outlined),
                child: Autocomplete<ItemsModel>(
                  onSelected: (item) {
                    selectedItem = item;
                  },
                  displayStringForOption: (item) {
                    return item.name;
                  },
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<ItemsModel>.empty();
                    }
                    return listItem.where((ItemsModel option) {
                      return option.name
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: false),
                  controller: _purchasePrice,
                  style: inputstyle(),
                  decoration: inputdec("Purchase Price *", Icons.price_change)),
              SizedBox(
                height: 20,
              ),
              TextField(
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: false),
                  controller: _salesPrice,
                  style: inputstyle(),
                  decoration: inputdec("Sales Price *", Icons.price_change)),
              SizedBox(
                height: 20,
              ),
              TextField(
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: false),
                  controller: _qty,
                  style: inputstyle(),
                  decoration:
                      inputdec("Qty*", Icons.shopping_cart_checkout_outlined)),
              SizedBox(
                height: 20,
              ),
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
                    submitPurchase();
                  })
            ],
          ),
        ),
      ),
    );
  }

  submitPurchase() {
    if (selectedItem == null) {
      showToast("Please Select Item from dropdown");
      return;
    }
    if (_qty.text.isEmpty) {
      showToast("Invalid qty");
      return;
    }
    if (_purchasePrice.text.isEmpty) {
      showToast("Invalid Purchase price");
      return;
    }
    if (_salesPrice.text.isEmpty) {
      showToast("Invalid Sales price");
      return;
    }

    try {
      itms.doc(uid).collection("items").doc(selectedItem!.docId).update({
        "qty": int.parse(_qty.text) + selectedItem!.qty,
        "purchase_price": int.parse(_purchasePrice.text),
        "sales_price": int.parse(_purchasePrice.text)
      });
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  getItems() {
    listItem.clear();
    var x = itms.doc(uid).collection("items").get().then((value) {
      for (var element in value.docs) {
        ItemsModel itemsModel = ItemsModel();
        itemsModel.name = element.data()["name"];
        itemsModel.description = element.data()["description"];
        itemsModel.purchasePrice = element.data()['purchase_price'];
        itemsModel.qty = element.data()['qty'];
        itemsModel.docId = element.id;
        listItem.add(itemsModel);
      }
      setState(() {});
    });
  }
}

showToast(text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
