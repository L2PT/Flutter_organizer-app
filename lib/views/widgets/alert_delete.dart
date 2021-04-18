import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/alert_base.dart';

class ConfirmCancelAlert {
  final BuildContext context;
  final String title;
  final String text;
  late List<Widget> _actions;
  late Widget _content;

  ConfirmCancelAlert(this.context, {required this.title, required this.text}) {

      _actions = <Widget>[
      TextButton(
        child: new Text('Annulla', style: label),
        onPressed: () {
          Navigator.pop(context, false);
        },
      ),
      SizedBox(
        width: 15,
      ),
      ElevatedButton(
        child: new Text('CONFERMA', style: button_card),
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




