import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class EmptyEvent extends StatelessWidget {

  final void Function() onPressedFunction;
  final String titleMessage;
  final String subtitleMessage;

  EmptyEvent({required this.onPressedFunction, this.titleMessage = "Nessun intervento in programma per questa data", this.subtitleMessage = ''});

  @override
  Widget build(BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          no_events_image,
          SizedBox(height: 30,),
          Text(titleMessage, style: title, textAlign: TextAlign.center,),
          Padding(padding: EdgeInsets.only(top: 5), child: Text(subtitleMessage, style: subtitle,)),
          SizedBox(height: 20,),
          ElevatedButton(
            child: new Text('VEDI CALENDARIO', style: button_card),
            onPressed: onPressedFunction,
          ),
        ],
      );
  }

}