import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/base_alert.dart';

class DeleteAlert extends  StatelessWidget {

  DeleteAlert({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget action = Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      FlatButton(
        child: new Text('Annulla', style: label),
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.canPop(context) ? Navigator.of(context).pop() : null;
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
          Navigator.pop(context, false);
          Navigator.pop(context, Constants.DELETE_SIGNAL);
          Navigator.canPop(context) ? Navigator.pop(context, Constants.DELETE_SIGNAL) : null;
        },
      ),
    ]);

    final Widget content = SingleChildScrollView(
      child: ListBody(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "Confermi la cancellazione dell'incarico?",
            style: label,
          ),
        ),
      ]),
    );

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Alert(
            action: action,
            content: content,
            title: "CANCELLA INCARICO",
          );
        });
  }

}




