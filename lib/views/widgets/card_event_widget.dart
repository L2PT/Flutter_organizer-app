import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/base_alert.dart';
import 'package:venturiautospurghi/views/widgets/delete_alert.dart';

class cardEvent extends StatefulWidget {
  final Event e;
  final int hourSpan;
  final double hourHeight;
  final DateTime selectedDay;
  final bool buttonArea;
  final void Function(Event) actionEvent;
  final bool dateView;

  final _formDateKey = GlobalKey<FormState>();

  cardEvent({this.e,
    this.hourSpan,
    this.hourHeight,
    this.selectedDay,
    this.actionEvent,
    this.buttonArea,
    this.dateView, Key key}) : super(key: key);

  @override
  _cardEventState createState() => _cardEventState();
}

class _cardEventState extends State<cardEvent> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_actionEvent != null) {
          return _actionEvent(widget.e);
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
    String oraInizio = formatter.format(widget.e.start);
    String oraFine = formatter.format(widget.e.end);
    double hour;
    double containerHeight;
    double paddingContainer;
    double heightBar;
    if (widget.hourSpan == 0) {
      containerHeight = widget.hourHeight;
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
                        color: HexColor(widget.e.color)),
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
                            style: time_card,
                          ),
                          Text(
                            widget.e.title.toUpperCase(),
                            style: title_rev,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(widget.e.category.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: subtitle_rev.copyWith(
                                  color: HexColor(widget.e.color),
                                  fontWeight: FontWeight.normal)),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                    ),
                  ),
                  widget.dateView
                      ? Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 15),
                      child: Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                            color: HexColor(widget.e.color),
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
                                      .format(widget.e.start)
                                      .toUpperCase(),
                                  style:
                                  title_rev.copyWith(fontSize: 16)),
                            ),
                            Center(
                              child: Text("${widget.e.start.day}",
                                  style:
                                  title_rev.copyWith(fontSize: 16)),
                            ),
                            Center(
                              child: Text(formatterSett.format(widget.e.start),
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
              widget.buttonArea ?
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: RaisedButton(
                      child: new Text('RIFIUTA', style: button_card),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(15.0))),
                      color: HexColor(widget.e.color),
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
                      color: HexColor(widget.e.color),
                      elevation: 15,
                      onPressed: () => _actionConferma(),
                    ),
                    margin: EdgeInsets.only(right: 10),
                  )
                ],
              ) : Container()
            ],
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        elevation: 5,
        color: black,
      );
    } else {
      hour = (((widget.e.end.day!=widget.selectedDay.day?Constants.MAX_WORKTIME*60:min<int>(Constants.MAX_WORKTIME*60,widget.e.end.hour * 60 + widget.e.end.minute)) -
          (widget.e.start.day!=widget.selectedDay.day?Constants.MIN_WORKTIME*60:max<int>(Constants.MIN_WORKTIME*60,widget.e.start.hour * 60 + widget.e.start.minute))) / 60);
      containerHeight = hour / widget.hourSpan * widget.hourHeight;
      paddingContainer = 5 * hour / widget.hourSpan;
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
                        color: HexColor(widget.e.color)),
                    width: 6,
                    height: heightBar,
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.e.title.toUpperCase(),
                          style: title_rev,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(widget.e.category.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: subtitle_rev.copyWith(
                                color: HexColor(widget.e.color),
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
        color: black,
      );
    }
    return r;
  }

  void _actionEvent(Event e) {
    widget.actionEvent(e);
  }

  void _actionRifiuta() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Alert(
          action: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: new Text('Annulla', style: label),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: 15,),
                RaisedButton(
                  child: new Text('CONFERMA', style: button_card),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(15.0))),
                  color: black,
                  elevation: 15,
                  onPressed: () => _actionFormRifiuta(context),
                ),
              ]),
          content: Form(
            key: widget._formDateKey,
            child: SingleChildScrollView(
              child: ListBody(children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Inserisci la motivazione del rifiuto',style: label,),
                ),
                TextFormField(
                  maxLines: 5,
                  cursorColor: black,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Motivazione rifiuto',
                    hintStyle: subtitle,
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: red, width: 1.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: grey_light2, width: 1.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: grey_light2, width: 1.0)),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: red, width: 1.0),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  validator: (value) =>
                  value.trim() == "" ? "Inserisci la motivazione" : null,
                  onSaved: (String value) => widget.e.motivazione = value,
                ),
              ]),
            ),
          ),
          title: "RIFIUTA INCARICO",
        );
      },
    );
  }

  void _actionConferma() {
    EventsRepository().updateEvent(widget.e, "Stato", Status.Accepted);
    widget.e.status = Status.Accepted;
    Account operator = BlocProvider.of<AuthenticationBloc>(context).account;
    Utils.notify(token:Account.fromMap(widget.e.idSupervisor, widget.e.supervisor).token, title: operator.surname+" "+operator.name+" ha accettato un lavoro");
  }

  void _actionFormRifiuta(BuildContext context) {
    if (widget._formDateKey.currentState.validate()) {
      widget._formDateKey.currentState.save();
      widget.e.status = Status.Refused;
      EventsRepository().refuseEvent(widget.e);
      Account operator = BlocProvider.of<AuthenticationBloc>(context).account;
      Utils.notify(token:Account.fromMap(widget.e.idSupervisor, widget.e.supervisor).token, title: operator.surname+" "+operator.name+" ha rifiutato un lavoro con la seguente motivazione:\n"+widget.e.motivazione);
      Navigator.of(context).pop();
    }
  }


}
