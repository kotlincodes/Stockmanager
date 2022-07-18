import 'package:flutter/material.dart';

inputdec(var title, var icn) => new InputDecoration(
    fillColor: Colors.white,
    filled: true,
    border: new OutlineInputBorder(),
    focusedBorder: new OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: new BorderSide(color: Colors.cyan)),
    enabledBorder: new OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: new BorderSide(color: Colors.black)),
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    // hintStyle: TextStyle(
    //   fontSize: 16, // or whatever
    //   color: Colors.grey,
    //   height: 2.2, //                                <----- this was the key
    // ),
    prefixIcon: Icon(
      icn,
      size: 20,
      color: Colors.black,
    ),
    contentPadding: EdgeInsets.all(0),
    isDense: true,
    labelText: "$title");

inputstyle() => const TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay');
