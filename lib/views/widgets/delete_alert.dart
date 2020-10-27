import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/base_alert.dart';

class ConfirmCancelAlert {
  final BuildContext context;
  final String title;
  final String text;
  List<Widget> _actions;
  Widget _content;

  ConfirmCancelAlert(this.context, {this.title, this.text}) {

      _actions = <Widget>[
      FlatButton(
        child: new Text('Annulla', style: label),
        onPressed: () {
          Navigator.pop(context, false);
        },
      ),
      SizedBox(
        width: 15,
      ),
      RaisedButton(
        child: new Text('CONFERMA', style: button_card),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        color: black,
        elevation: 15,
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
    ];

    _content = SingleChildScrollView(
      child: ListBody(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text( text, style: label, ),
        ),
      ]),
    );
  }

  Future<bool> show() async => await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Alert(
          actions: _actions,
          content: _content,
          title: title,
        );
      });
}




