import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class EmptyEvent extends StatelessWidget {

  final void Function() onPressedFunction;
  final String textMessage;
  final String subMessage;

  EmptyEvent({required this.onPressedFunction, this.textMessage = "Nessun intervento in programma per questa data", this.subMessage = ''});

  @override
  Widget build(BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          no_events_image,
          SizedBox(height: 30,),
          Text(textMessage,style: title, textAlign: TextAlign.center,),
          Padding(padding: EdgeInsets.only(top: 5), child: Text(subMessage, style: subtitle,)),
          SizedBox(height: 20,),
          ElevatedButton(
            child: new Text('VEDI CALENDARIO', style: button_card),
            onPressed: onPressedFunction,
          ),
        ],
      );
  }

}