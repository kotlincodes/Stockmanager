import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final List<ItemsModel> listItem = [];
  final TextEditingController _itemname = TextEditingController();
  final TextEditingController _itemPrice = TextEditingController();
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
        title: Text("Sales"),
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
                  controller: _itemPrice,
                  style: inputstyle(),
                  decoration: inputdec("Item Price *", Icons.price_change)),
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
    if (_itemPrice.text.isEmpty) {
      showToast("Invalid price");
      return;
    }
    try {
      itms
          .doc(uid)
          .collection("Purchase")
          .where("Name", isEqualTo: selectedItem!.name)
          .get()
          .then((value) {
        if (value.docs.isEmpty) {
          showToast("Stock is not available");
        } else if (value.docs[0].data()["qty"] < int.parse(_qty.text)) {
          showToast("Qty available is ${value.docs[0].data()["qty"]}");
        } else {
          itms.doc(uid).collection("sales").doc().set({
            'Name': selectedItem?.name ?? "",
            'Description': selectedItem?.description ?? "",
            "qty": int.parse(_qty.text),
            "price": _itemPrice.text,
            "timestamp": DateTime.now()
          });
          itms
              .doc(uid)
              .collection("Purchase")
              .doc(value.docs[0].id)
              .update({"qty": value.docs[0]["qty"] - int.parse(_qty.text)});
          Navigator.pop(context);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  getItems() {
    listItem.clear();
    var x = itms.doc(uid).collection("Items").get().then((value) {
      value.docs.forEach((element) {
        ItemsModel itemsModel = ItemsModel();
        itemsModel.name = element.data()["Name"];
        itemsModel.description = element.data()["Description"];
        listItem.add(itemsModel);
      });
      setState(() {});
    });
  }

  showToast(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

class ItemsModel {
  String name = "";
  String description = "";
}
