import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/base_alert.dart';

class RejectAlert{
  final TextEditingController _controller = TextEditingController();
  final BuildContext context;
  List<Widget> _actions;
  Widget _content;

  RejectAlert(this.context) {

    _actions = <Widget>[
      FlatButton(
        child: new Text('Annulla'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      SizedBox(width: 15,),
      RaisedButton(
        child: new Text('CONFERMA'),
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(15.0))),
        color: Colors.black,
        elevation: 15,
        onPressed: () => Navigator.pop(context, _controller.text),
      ),
    ];

    _content = SingleChildScrollView(
      child: ListBody(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('Inserisci la motivazione del rifiuto'),
        ),
        TextFormField(
          maxLines: 5,
          cursorColor: Colors.black,
          controller: _controller,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Motivazione',
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1.0)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.0)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.0)),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.0),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ]),
    );
  }

  Future<String> show() async => await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Alert(
        actions: _actions,
        content: _content,
        title: "RIFIUTA INCARICO",
      );
    });
}