import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/utils/colors.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'dart:io' show Platform;

class cardEvent extends StatelessWidget {
  final Event event;
  final DateTime selectedDay;
  final void Function(Event) onTapAction;
  final Map<String, Function(Event)> buttonArea;
  final int gridHourSpan;
  final double hourHeight;
  final bool dateView;

  cardEvent({@required this.event,
    this.selectedDay,
    this.onTapAction,
    this.buttonArea,
    this.gridHourSpan = 0,
    this.hourHeight = 160,
    this.dateView = false}): assert(gridHourSpan!=0?selectedDay!=null:true);


  @override
  Widget build(BuildContext context) {

    Widget _buildButton(String text, Function onPressedAction) => Container(
      child: RaisedButton(
        child: new Text(text, style: button_card),
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(15.0))),
        color: HexColor(event.color),
        elevation: 15,
        onPressed: () {
          onPressedAction.call(event);
        },
      ),
      margin: EdgeInsets.only(right: 10),
    );

    Widget _buildCardEvent() {
      Widget card;
      double hoursDurationEvent;
      double containerHeight;
      double paddingContainer;
      double heightBar;

      if (gridHourSpan == 0) {
        containerHeight = hourHeight;
        paddingContainer = 15;
        heightBar = 60;

        card = Card(
          child: Container(
            height: containerHeight,
            padding: EdgeInsets.only(left: 10, top: paddingContainer),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: HexColor(event.color)),
                      width: 6,
                      height: heightBar,
                      margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(DateFormat('HH : mm', 'it_IT').format(event.start) + '  -  ' + DateFormat('HH : mm', 'it_IT').format(event.end),
                              style: time_card,
                            ),
                            Text(
                              event.title.toUpperCase(),
                              style: title_rev,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(event.category.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: subtitle_rev.copyWith(
                                    color: HexColor(event.color),
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                      ),
                    ),
                    if(dateView)
                      Expanded(
                        flex: 3,
                        child: Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 15),
                          child: Container(
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                                color: HexColor(event.color),
                                borderRadius:
                                BorderRadius.all(Radius.circular(25.0))),
                            width: 55,
                            height: 90,
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Center(
                                  child: Text(DateFormat('MMM', "it_IT").format(event.start) .toUpperCase(),
                                      style: title_rev.copyWith(fontSize: 15)),
                                ),
                                Center(
                                  child: Text("${event.start.day}",
                                      style: title_rev.copyWith(fontSize: 15)),
                                ),
                                Center(
                                  child: Text(DateFormat('E', "it_IT").format(event.start),
                                      style: title_rev.copyWith(fontSize: 15, fontWeight: FontWeight.normal)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if(buttonArea != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: buttonArea.entries.map((entry)=>_buildButton(entry.key, entry.value)).toList(),
                  )
              ],
            ),
          ),
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
          elevation: 5,
          color: black,
        );
      } else {
        hoursDurationEvent = (((event.end.day!=selectedDay.day?Constants.MAX_WORKTIME*60:min<int>(Constants.MAX_WORKTIME*60,event.end.hour * 60 + event.end.minute)) -
            (event.start.day!=selectedDay.day?Constants.MIN_WORKTIME*60:max<int>(Constants.MIN_WORKTIME*60,event.start.hour * 60 + event.start.minute))) / 60);
        containerHeight = hoursDurationEvent / gridHourSpan * hourHeight;
        heightBar = 40;

        card = Card(
          child: Container(
            height: containerHeight,
            child: Flexible(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: HexColor(event.color)),
                        width: 6,
                        height: heightBar,
                        margin: const EdgeInsets.symmetric(horizontal: 15.0),
                      ),
                      Expanded(
                          child:Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  event.title.toUpperCase(),
                                  style: title_rev,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                Text(event.category.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: subtitle_rev.copyWith(
                                      color: HexColor(event.color),
                                      fontWeight: FontWeight.normal)),
                              ],
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
          elevation: 5,
          color: black,
        );
      }
      return card;
    }

    return GestureDetector(
      onTap: () { onTapAction?.call(event); },
      child: _buildCardEvent(),
    );
  }

}
