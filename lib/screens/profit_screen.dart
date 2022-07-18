import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/model/item_model.dart';

class ProfitScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StateProfitScreen();
}

class _StateProfitScreen extends State<ProfitScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfitList();
  }

  DateTime? from;
  CollectionReference itms = FirebaseFirestore.instance.collection("users");
  List<ItemsModel> listItem = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profit")),
      body: Container(
        padding: EdgeInsets.all(12),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onDateChanged: (date) {
                  selectedDate =
                      DateTime(date.year, date.month, date.day, 23, 59);
                  getProfitList();
                },
              ),
            )),
            SizedBox(
              height: 24,
            ),
            Text(
              "From : ${dateFormatter.format(selectedDate)} To ${dateFormatter.format(DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 7))}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 24,
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: listItem.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                listItem[index].name.toUpperCase(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Sales Count: ${listItem[index].qty}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Profit: ${getProfit(listItem[index])}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Sales Price: ${listItem[index].salesPrice}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Purchase Price: ${listItem[index].purchasePrice}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
          ],
        ),
      ),
    );
  }

  getProfitList() {
    isLoading = true;
    setState(() {});
    itms
        .doc(uid)
        .collection("sales")
        .where('timestamp', isLessThan: selectedDate)
        .where("timestamp",
            isGreaterThan: DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day - 7))
        .get()
        .then((value) {
      listItem.clear();
      for (var element in value.docs) {
        var found = false;
        for (int i = 0; i < listItem.length; i++) {
          if (element.data()["name"] == listItem[i].name) {
            listItem[i].qty =
                listItem[i].qty + int.parse(element.data()['qty'].toString());
            found = true;
            break;
          }
        }
        if (found == true) {
          continue;
        }

        ItemsModel itemsModel = ItemsModel();
        itemsModel.name = element.data()["name"];
        itemsModel.description = element.data()["description"];
        itemsModel.purchasePrice = element.data()['purchase_price'];
        itemsModel.salesPrice = element.data()['sales_price'] ?? 0;
        itemsModel.qty = element.data()['qty'];
        itemsModel.docId = element.id;
        listItem.add(itemsModel);
      }
      isLoading = false;
      setState(() {});
    });
  }

  String getProfit(ItemsModel itemsModel) {
    return ((itemsModel.salesPrice - itemsModel.purchasePrice) * itemsModel.qty)
        .toString();
  }
}
