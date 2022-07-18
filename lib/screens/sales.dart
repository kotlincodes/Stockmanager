import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/model/item_model.dart';
import 'package:flutter_application_1/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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
  final TextEditingController _date = TextEditingController();
  final TextEditingController _qty = TextEditingController();
  CollectionReference itms = FirebaseFirestore.instance.collection("users");
  GlobalKey<AutoCompleteTextFieldState<ItemsModel>> key =
      GlobalKey<AutoCompleteTextFieldState<ItemsModel>>();
  ItemsModel? selectedItem;
  DateTime? selecetdDate;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InputDecorator(
                decoration: inputdec(
                    "Item Name *", Icons.shopping_cart_checkout_outlined),
                child: Autocomplete<ItemsModel>(
                  onSelected: (item) {
                    selectedItem = item;
                    setState(() {});
                  },
                  displayStringForOption: (item) {
                    return item.name;
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onEditingComplete: () {
                        print("EDIT_COMPLETE");
                      },
                      decoration:
                          new InputDecoration.collapsed(hintText: 'Item '),
                      onChanged: (text) {
                        if (text != selectedItem?.name) {
                          selectedItem = null;
                          setState(() {});
                        }
                      },
                    );
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
                height: 10,
              ),
              selectedItem != null && selectedItem!.qty != 0
                  ? Text("Purchase price : ${selectedItem!.purchasePrice}")
                  : Container(),
              selectedItem != null && selectedItem!.qty != 0
                  ? Text("Sales price : ${selectedItem!.salesPrice}")
                  : Container(),
              selectedItem != null && selectedItem!.qty != 0
                  ? Text("Stock : ${selectedItem!.qty}")
                  : Container(),
              selectedItem != null && selectedItem!.qty == 0
                  ? Text(
                      "Stock not avalable, Please add stock ",
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(
                height: 20,
              ),
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
              TextField(
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: false),
                  controller: _date,
                  style: inputstyle(),
                  readOnly: true,
                  onTap: () {
                    showDatePicker();
                  },
                  decoration:
                      inputdec("Date*", Icons.shopping_cart_checkout_outlined)),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                  minWidth: double.infinity,
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
                  onPressed: selectedItem != null && selectedItem!.qty != 0
                      ? submitPurchase
                      : null)
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

    if (selecetdDate == null) {
      showToast("Please Select date");
      return;
    }
    if (_qty.text.isEmpty) {
      showToast("Invalid qty");
      return;
    }

    if (int.parse(_qty.text) > selectedItem!.qty) {
      showToast("Stock is not availabe");
      return;
    }
    try {
      itms.doc(uid).collection("sales").doc().set({
        'name': selectedItem?.name ?? "",
        'purchase_price': selectedItem!.purchasePrice,
        'sales_price': selectedItem!.salesPrice,
        'description': selectedItem?.description ?? "",
        "qty": int.parse(_qty.text),
        "timestamp": selecetdDate
      }).then((value) {
        itms
            .doc(uid)
            .collection("items")
            .doc(selectedItem!.docId)
            .update({"qty": selectedItem!.qty - int.parse(_qty.text)});
        Navigator.pop(context);
      });
    } catch (e) {
      print(e);
    }
  }

  showDatePicker() {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            margin: EdgeInsets.symmetric(
                horizontal: 36,
                vertical: MediaQuery.of(context).size.height * .2),
            child: SfDateRangePicker(
              maxDate: DateTime.now(),
              confirmText: "Submit",
              onCancel: () {
                Navigator.pop(context);
              },
              onSubmit: (p0) {
                if (p0 == null) {
                  showToast("Please select valid date ");
                  return;
                }
                selecetdDate = p0 as DateTime;
                _date.text = dateFormatter.format(p0);
                Navigator.pop(context);
              },
              showActionButtons: true,
              selectionMode: DateRangePickerSelectionMode.single,
              backgroundColor: Colors.white,
            ),
          );
        });
  }

  getItems() {
    listItem.clear();
    var x = itms.doc(uid).collection("items").get().then((value) {
      for (var element in value.docs) {
        ItemsModel itemsModel = ItemsModel();
        itemsModel.name = element.data()["name"];
        itemsModel.description = element.data()["description"];
        itemsModel.purchasePrice = element.data()['purchase_price'];
        itemsModel.salesPrice = element.data()['sales_price'];
        itemsModel.qty = element.data()['qty'];
        itemsModel.docId = element.id;
        listItem.add(itemsModel);
      }
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
