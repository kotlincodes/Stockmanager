import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/item_model.dart';
import 'package:flutter_application_1/screens/profit_screen.dart';
import 'package:flutter_application_1/screens/purchase.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:collection/collection.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../main.dart';

class ReportScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StateReprotScreen();
}

class _StateReprotScreen extends State<ReportScreen> {
  CollectionReference itms = FirebaseFirestore.instance.collection("users");
  List<Map<String, Object>> listItem = [];
  var endDate = DateTime.now();
  DateTime? startDate;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startDate = DateTime(endDate.year, endDate.month, endDate.day - 7);
    getProfitList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Report")),
      body: Column(
        children: [
          Card(
              color: Colors.amber,
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: MaterialButton(
                onPressed: () {
                  // showDatePicker();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfitScreen()));
                },
                child: Text("Get Profit"),
                minWidth: double.infinity,
              )),
          ListTile(
            onTap: () {
              showDatePicker();
            },
            trailing: Icon(
              Icons.calendar_month,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Graph - ${dateFormatter.format(startDate!)} - ${dateFormatter.format(endDate)}",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : getChart(),
          )
        ],
      ),
    );
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
              initialSelectedRange: PickerDateRange(startDate, endDate),
              confirmText: "Submit",
              onCancel: () {
                Navigator.pop(context);
              },
              onSubmit: (p0) {
                var x = p0 as PickerDateRange;
                if (x.startDate == null || x.endDate == null) {
                  showToast("Please select valid date range");
                  return;
                }
                startDate = p0.startDate;
                endDate = DateTime(p0.endDate!.year, p0.endDate!.month,
                    p0.endDate!.day, 23, 59);
                getProfitList();
                Navigator.pop(context);
              },
              showActionButtons: true,
              selectionMode: DateRangePickerSelectionMode.range,
              backgroundColor: Colors.white,
            ),
          );
        });
  }

  getProfitList() {
    isLoading = true;
    setState(() {});
    itms
        .doc(uid)
        .collection("sales")
        .where('timestamp', isLessThan: endDate)
        .where("timestamp", isGreaterThan: startDate)
        .orderBy("timestamp", descending: false)
        .get()
        .then((value) {
      listItem.clear();
      var prevDate = startDate;

      for (int i = 0; i <= endDate.difference(startDate!).inDays; i++) {
        Map<String, Object> chartValueZero = {};
        chartValueZero['date'] =
            dateFormatter.format(startDate!.add(Duration(days: i)));
        chartValueZero['profit'] = "0";
        listItem.add(chartValueZero);
      }

      for (var element in value.docs) {
        Map<String, Object> chartValues = {};

        var date = (element.data()["timestamp"] as Timestamp).toDate();
        var item = listItem.firstWhereOrNull(
            (data) => data['date'] == dateFormatter.format(date));

        if (item != null) {
          item['profit'] = (int.parse(item['profit'].toString()) +
                  int.parse(getProfit(element.data()["sales_price"],
                      element.data()["purchase_price"], element.data()["qty"])))
              .toString();
          continue;
        }

        // var tempDate = DateTime(date.year, date.month, date.day - 1);
        // while (prevDate != tempDate) {
        //   tempDate = DateTime(tempDate.year, tempDate.month, tempDate.day - 1);
        //   Map<String, Object> chartValueZero = {};
        //   chartValueZero['date'] = dateFormatter.format(prevDate!);
        //   chartValueZero['profit'] = "0";
        //   listItem.add(chartValueZero);
        // }
        // prevDate = DateTime(date.year, date.month, date.day);
        // chartValues['date'] = dateFormatter.format(date);

        // chartValues['profit'] = getProfit(element.data()["sales_price"],
        //     element.data()["purchase_price"], element.data()["qty"]);
        // listItem.add(chartValues);
      }
      isLoading = false;
      setState(() {});
    });
  }

  String getProfit(int salesPrice, int purPrice, int qty) {
    return ((salesPrice - purPrice) * qty).toString();
  }

  getChart() {
    print({jsonEncode(listItem)});
    return SizedBox(
      child: Echarts(
        option: '''
                            {
                              dataset: {
                                dimensions: ['date', 'profit'],
                                source: ${jsonEncode(listItem)},
                              },
                              color: ['#058FC2','#64BD01'],

                              grid: {
                                left: '0%',
                                right: '0%',
                                bottom: '5%',
                                top: '12%',
                                height: '85%',
                                containLabel: true,
                                z: 22,
                              },
                              xAxis: [{
                                type: 'category',
                                gridIndex: 0,
                                boundaryGap: false,
                                
                                axisLine: {
                                  lineStyle: {
                                    color: '#6ad2ce',
              width: 2,
                                  },
                                },
                                axisLabel: {
                                  show: true,
                                  color: '#333',
            lineHeight: 20,
                                  formatter: function xFormatter(value, index) {
                
                                    return value;
                                  },
                                },
                              }],
                              yAxis: {
                                type: 'value',
                                 name:'Profit',
                                 nameTextStyle: {
            color: '#6ad2ce',
          },
                                gridIndex: 0,
                                splitLine: {
                                  show: false,
                                },
                               axisLine: {
            show: false,
          },
                                axisLine: {
                                  lineStyle: {
                                    color: '#0c3b71',
                                  },
                                },
                                axisLabel: {
                                  color: '#333',
                                },
                                splitNumber: 6,
                                 splitLine: {
            lineStyle: {
              type: 'dashed',
              color: '#6ad2ce',
            },
          },
                              },
                              series: [{
                                name: 'Data1',
                                type: 'line',
 smooth: 0.35,
  symbol: 'circle',
  symbolSize: 5,
      areaStyle: {
        opacity: 0.33
      }

                              }
                             
                              ],
                            }
                          ''',
        extraScript: '''
                            chart.on('click', (params) => {
                              if(params.componentType === 'series') {
                                Messager.postMessage(JSON.stringify({
                                  type: 'select',
                                  payload: params.dataIndex,
                                }));
                              }
                            });
                          ''',
        captureAllGestures: true,
        onMessage: (String message) {
          // Map<String, dynamic> messageAction = jsonDecode(message);
          // print(messageAction);
          // if (messageAction['type'] == 'select') {
          //   final item = controller.chartdata1[messageAction['payload']];
          //   controller.selectedTime = item!['name'].toString();
          //   controller.received = item!['data2'].toString();
          //   controller.transmitted = item!['data1'].toString();
          // }
        },
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 7 / 10,
    );
  }
}
