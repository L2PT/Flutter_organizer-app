import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/view/widget/card_event_widget.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class WaitingEvent extends StatefulWidget {
  DateTime day;

  WaitingEvent({this.day, Key key}) : super(key: key);

  @override
  _WaitingEventState createState() => _WaitingEventState();
}

class _WaitingEventState extends State<WaitingEvent> {
  Map<int, List> _events;
  List _selectedEvents;
  DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.day != null ? widget.day : DateTime.now();
    final _today = DateTime.now();
    //TURRO se guardi il daily o il calendar prendo gli eventi del db. Ho fixato la mappa degli eventi come mi hai detto qui ho lasciato statico così fai te
    //e li gestisci come preferisci
    //Firebase getter events
    _events = {
      _today.day: [
        Event("PULIZIA IMPIANTI", "", DateTime(2019, 8, 11, 7, 0, 0),
            DateTime(2019, 8, 11, 8, 0, 0), "", "Spurghi"),
        Event("PULIZIE INDUSTRIALI", "", DateTime(2019, 8, 11, 10, 0, 0),
            DateTime(2019, 8, 11, 11, 0, 0), "", "Fogne"),
        Event("RACCOLTA OLI", "", DateTime(2019, 8, 11, 15, 0, 0),
            DateTime(2019, 8, 11, 16, 0, 0), "", "Tombini")
      ]
    };
    ///////////////

    _selectedEvents = _events[_selectedDay.day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      elevation: 12.0,
      borderRadius: new BorderRadius.only(
          topLeft: new Radius.circular(16.0),
          topRight: new Radius.circular(16.0)),
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: _buildWaitingEvent(),
        ),
      ),
    );
  }

  List<Widget> _buildWaitingEvent() {
    List<Widget> r = new List<Widget>();
    var formatter = new DateFormat('MMMM yyyy', 'it_IT');
    print(_selectedEvents);
    _selectedEvents.forEach((e) {
      int day = e.start.day;
      String meseAnno = formatter.format(e.start);
      r.add(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    '$day',
                    style: dayWaitingEvent,
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Text(
                    meseAnno.toUpperCase(),
                    style: datWaitingEvent,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: new Icon(Icons.today),
                      alignment: Alignment.centerRight,
                      color: Colors.grey,
                      onPressed: () {
                        print("Pressed");
                      }),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 9,
                  child: Center(
                    child: new Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 0.0, bottom: 15.0),
                        child: Divider(
                          color: Colors.grey,
                          height: 0,
                        )),
                  ),
                ),
              ],
            ),
            Row(children: <Widget>[
              Expanded(
                flex: 9,
                child: cardEvent(
                  e: e,
                  hourHeight: 120,
                  buttonArea: true,
                ),
              ),
            ]),
            SizedBox(height: 15)
          ]));
    });
    return r;
  }
}
