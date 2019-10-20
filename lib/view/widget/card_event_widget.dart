import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class cardEvent extends StatelessWidget {
  final Event e;
  final int hourSpan;
  final double hourHeight;
  final bool buttonArea;
  final void Function(Event) actionEvent;
  final bool dateView;

  cardEvent(
      {this.e,
      this.hourSpan,
      this.hourHeight,
      this.actionEvent,
      this.buttonArea,
      this.dateView});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_actionEvent != null) {
          return _actionEvent(e);
        }
      },
      child: _buildCardEvent(),
    );
  }

  Widget _buildCardEvent() {
    Widget r = null;
    var formatter = new DateFormat('HH : mm', 'it_IT');
    DateFormat formatterMese = new DateFormat('MMM', "it_IT");
    DateFormat formatterSett = new DateFormat('E', "it_IT");
    String oraInizio = formatter.format(e.start);
    String oraFine = formatter.format(e.end);
    double hour;
    double containerHeight;
    double paddingContainer;
    double heightBar;
    if (buttonArea) {
      containerHeight = this.hourHeight;
      paddingContainer = 15;
      heightBar = 60;
      r = Card(
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
                        color: HexColor(e.color)),
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
                          Text(
                            oraInizio + '  -  ' + oraFine,
                            style: orario_card,
                          ),
                          Text(
                            e.title.toUpperCase(),
                            style: title_rev,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(e.category.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: subtitle_rev.copyWith(
                                  color: HexColor(e.color),
                                  fontWeight: FontWeight.normal)),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                    ),
                  ),
                  dateView
                      ? Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(right: 15),
                            child: Container(
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                  color: HexColor(e.color),
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
                                    child: Text(
                                        formatterMese
                                            .format(e.start)
                                            .toUpperCase(),
                                        style:
                                            title_rev.copyWith(fontSize: 16)),
                                  ),
                                  Center(
                                    child: Text("${e.start.day}",
                                        style:
                                            title_rev.copyWith(fontSize: 16)),
                                  ),
                                  Center(
                                    child: Text(formatterSett.format(e.start),
                                        style: title_rev.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: RaisedButton(
                      child: new Text('RIFIUTA', style: button_card),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.0))),
                      color: HexColor(e.color),
                      elevation: 15,
                      onPressed: () => _actionRifiuta(),
                    ),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Container(
                    child: RaisedButton(
                      child: new Text('CONFERMA', style: button_card),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.0))),
                      color: HexColor(e.color),
                      elevation: 15,
                      onPressed: () => _actionConferma(),
                    ),
                    margin: EdgeInsets.only(right: 10),
                  )
                ],
              )
            ],
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        elevation: 5,
        color: dark,
      );
    } else {
      hour = (((e.end.hour * 60 + e.end.minute) -
              (e.start.hour * 60 + e.start.minute)) /
          60);
      containerHeight = hour / this.hourSpan * this.hourHeight;
      paddingContainer = 5 * hour / this.hourSpan;
      heightBar = 40;
      r = Card(
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
                        color: HexColor(e.color)),
                    width: 6,
                    height: heightBar,
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          e.title.toUpperCase(),
                          style: title_rev,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(e.category.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: subtitle_rev.copyWith(
                                color: HexColor(e.color),
                                fontWeight: FontWeight.normal)),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                  )
                ],
              ),
            ],
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        elevation: 5,
        color: dark,
      );
    }
    return r;
  }

  void _actionEvent(Event e) {
    this.actionEvent(e);
  }

  void _actionRifiuta() {}

  void _actionConferma() {}
}
