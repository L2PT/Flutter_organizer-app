import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/alert/alert_base.dart';

class NotaAlert{
  final TextEditingController _controller = TextEditingController();
  final BuildContext context;
  late List<Widget> _actions;
  late Widget _content;
  final String text;
  final bool editMode;

  NotaAlert(this.context, {this.text = '', this.editMode = false}) {
    _controller.text = text;
    _actions = <Widget>[
      TextButton(
        child: new Text('Annulla'),
        onPressed: () {
          Navigator.of(context).pop(null);
        },
      ),
      SizedBox(width: 15,),
      ElevatedButton(
        child: new Text('SALVA', style: button_card),
        onPressed: () => Navigator.pop(context, _controller.text),
      ),
    ];

    _content = SingleChildScrollView(
      child: ListBody(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('Scrivi la nota o le informazioni che vuoi aggiungere al incarico.'),
        ),
        TextFormField(
          maxLines: 5,
          cursorColor: Colors.black,
          controller: _controller,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: editMode?"Modifica nota":'Aggiungi nota',
            hintStyle: subtitle,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1.0)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: grey_light, width: 1.0)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: grey, width: 1.0)),
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
          title: editMode?"MODIFICA NOTA":"INSERISCI NOTA",
        );
      });
}