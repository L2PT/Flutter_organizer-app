import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/alert/alert_base.dart';

class RefuseAlert{
  final TextEditingController _controller = TextEditingController();
  final BuildContext context;
  late List<Widget> _actions;
  late Widget _content;

  RefuseAlert(this.context) {

    _actions = <Widget>[
      TextButton(
        child: new Text('Annulla'),
        onPressed: () {
          Navigator.of(context).pop("");
        },
      ),
      SizedBox(width: 15,),
      ElevatedButton(
        child: new Text('CONFERMA', style: button_card),
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