import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';
a
class dialogAlert extends  StatelessWidget {

  final Widget content;
  final BuildContext context;
  final String tittle;
  final Widget action;

  dialogAlert(
      {this.content,
        this.context,
        this.tittle,
        this.action,
        Key key})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      title: Container(
        height: 50,
        decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0)),
          border: Border.all(color: black),
        ),
        child: Center(
          child: Text(
            tittle,
            style: title_rev,
          ),
        ),
      ),
      content: content,
      actions: <Widget>[
        action,
      ],
    );
  }

}




