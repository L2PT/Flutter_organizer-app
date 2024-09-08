import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/alert/alert_base.dart';

class ConfirmCancelAlert {
  final BuildContext context;
  final String title;
  final String text;
  final bool showDetailsContent;
  late List<Widget> _actions;


  ConfirmCancelAlert(this.context, {required this.title, required this.text, this.showDetailsContent = false});

  Future<List<bool>> show() async => await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        bool updateEndDate = false;
        return StatefulBuilder(
        builder: (context, setState) {
          return Alert(
            actions: <Widget>[
              TextButton(
                child: new Text('Annulla', style: label),
                onPressed: () {
                  Navigator.pop(context, [false, false]);
                },
              ),
              SizedBox(
                width: 15,
              ),
              ElevatedButton(
                child: new Text('CONFERMA', style: button_card),
                onPressed: () {
                  Navigator.pop(context, [true, updateEndDate]);
                },
              ),
            ],
            content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text( text, style: label, ),
                ),
                showDetailsContent?
                Row(children: [
                  Icon(Icons.update_outlined, color: updateEndDate?black:grey_dark, size: 25),
                  SizedBox(width: 5,),
                  Text("Aggiornare la data di fine",style: label.copyWith(color: updateEndDate?black:grey_dark),),
                  Switch(value: updateEndDate, onChanged: (value) {
                    setState((){ updateEndDate = value; });
                  },activeColor: yellow,)
                ])
                    : Container(),
              ]),
            ),
            title: title,
          );
        });
      });
}




