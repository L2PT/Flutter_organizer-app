/*
THIS IS THE MAIN PAGE OF THE OPERATOR
-l'appBar contiene menu a sinistra, titolo al centro
-in alto c'è una riga di giorni della settimana selezionabili
-(R)al centro e in basso c'è una grglia oraria dove sono rappresentati gli eventi dell'operatore corrente del giorno selezionato in alto
-(O)al centro e in basso c'è una grglia oraria dove sono rappresentati i propri eventi del giorno selezionato in alto
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/date_symbol_data_local.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/plugin/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/view/widget/card_event_widget.dart';
import '../utils/theme.dart';
import '../models/event.dart';
import 'details_event_view.dart';
import 'form_event_creator_view.dart';

//HANDLE cambia questa costante per modifcare la grandezza degli eventi
const double minEventHeight = 60.0;

class DailyCalendar extends StatefulWidget {
  DateTime day;
  DailyCalendar({ this.day, Key key}) : super(key: key);

  @override
  _DailyCalendarState createState() => _DailyCalendarState();
}

class _DailyCalendarState extends State<DailyCalendar> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  DateTime _selectedDay;
  AnimationController _animationController;
  CalendarController _calendarController;
  double _gridHourHeight;
  int _gridHourSpan;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.day!=null?widget.day:DateTime.now();
    _events = Map();
    _readEvents(_selectedDay);
    _selectedEvents = _events[Utils.formatDate(_selectedDay)] ?? [];
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
    _gridHourHeight = minEventHeight;
    _gridHourSpan = 1;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

      //MAIN BUILEDER METHODS
  @override
  Widget build(BuildContext context) {
    return new Material(
      elevation: 12.0,
      borderRadius: new BorderRadius.only(
          topLeft: new Radius.circular(16.0),
          topRight: new Radius.circular(16.0)),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

        //--CALENDAR
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'it_IT',
      calendarController: _calendarController,
      events: _events,
      holidays: global.Constants().holidays,
      initialCalendarFormat: CalendarFormat.week,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.horizontalSwipe,
      availableCalendarFormats: {CalendarFormat.week: ''},
      initialSelectedDay: _selectedDay,
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: dark,
                      width: 3
                  )
                )
              ),
              child: Center(
                child:Text(
                  '${date.day}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333),fontSize: 18)
              ),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 2),
            decoration: BoxDecoration(
              color: grey_light,
              borderRadius: BorderRadius.circular(10.0),
          ),
            child: Center(child:Text(
              '${date.day}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333),fontSize: 18)
            ),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];
          if (events.isNotEmpty && false) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }
          if (holidays.isNotEmpty && false) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }return children;
        },
      ),
      onDaySelected: (date, events) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      selectNext: (){Navigator.of(context).pushNamedAndRemoveUntil(global.Constants.monthlyCalendarRoute,
              (Route<dynamic> route) => true);},
      selectPrevious: (){},
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date) ? Colors.brown[300] : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

        //--EVENT LIST
  Widget _buildEventList() {
    return ListView(
        children:<Widget>[Stack(
            children: <Widget>[
              Column(
                  children: _buildBack((16/_gridHourSpan).toInt())
              ),Column(
                  children: _buildFront()
              )
            ]
        )]
    );
  }
  void initList() {
    if(_selectedEvents.length>0) {
      //order by start date
      setState(() {
        _selectedEvents.sort((a, b) => a.start.compareTo(b.start));
      });
      //identify minimum duration's event
      int md = 4;
      _selectedEvents.forEach((e) => {
        md = min(md.toInt(), (((e.end.hour * 60 + e.end.minute) -
            (e.start.hour * 60 + e.start.minute)) / 60).toInt())
      });
      if (md == 0) {
        setState(() {
          _gridHourHeight = minEventHeight * 2;
          _gridHourSpan = 1;
        });
      } else {
        int i = 0;
        while (md == (max(pow(2, i), md)))i++;
        md = (min(pow(2, i), md));
        setState(() {
          _gridHourHeight = minEventHeight;
          _gridHourSpan = md;
        });
      }
    }else{
      setState(() {
        _gridHourHeight = minEventHeight;
        _gridHourSpan = 1;
      });
    }
  }

  List<Widget> _buildBack(int length) {
    double barHourHeight = _gridHourHeight / 2;
    return List.generate(length, (i) {
      int n = ((i)*_gridHourSpan) + 6;
      return Row(children: <Widget>[Expanded(
          flex: 2,
          child: Container(
              padding: EdgeInsets.only(left: 20),
              height: _gridHourHeight,
              child: Center(
                child: Text("$n:00", style: TextStyle(color: grey_dark),),)
          )
      ),
        Expanded(
            flex: 8,
            child: Column(children: <Widget>
            [Container(
                  height: barHourHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 4, color: grey_light),
                    ),
                  )
              ), Container(
                height: barHourHeight,
              )
            ]
            )
        ),
      ]
      );
    }).toList();
  }

  List<Widget> _buildFront(){
    List<Widget> r = new List<Widget>();
    double barHourHeight = _gridHourHeight / 2;
    DateTime base = new DateTime(1990,1,1,6,0,0);
    DateTime top = new DateTime(1990,1,1,21,0,0);
    r.add(SizedBox(height: barHourHeight));
    this.initList();
    _selectedEvents.forEach((e){
      r.add(SizedBox(height: (((e.start.hour*60+e.start.minute)-(base.hour*60+base.minute))/60)*_gridHourHeight));
      r.add(
          Row(children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                    padding: EdgeInsets.only(right: 40),
                    height: (((e.end.hour*60+e.end.minute)-(e.start.hour*60+e.start.minute))/60)*_gridHourHeight,
                    child: Icon(Icons.notification_important,color: red)
                )
            ),
            Expanded(
              flex: 8,
              child: cardEvent(
                e:e,
                hourHeight:_gridHourHeight,
                actionEvent: _onCardClicked,
                buttonArea: false,
              )
            ),
          ])
      );
      base = e.end;
    });
    r.add(SizedBox(height: (((top.hour*60+top.minute)-(base.hour*60+base.minute))/60)*_gridHourHeight));
    return r;
  }

      //METODI DI CALLBACK
  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
    int period = 1;
    DateTime s = Utils.formatDate(first);
    if(format == CalendarFormat.week)period=7;
    else if(format == CalendarFormat.month)period=30;
    for(int i=0; i<period; i++){
      _readEvents(s.add(new Duration(days: i)));
    }
  }

  void _onCardClicked(Event ev) {
    Navigator.of(context).pushNamed(global.Constants.detailsEventViewRoute, arguments: ev);
  }

  void _deleteEvent(Event ev) {
    PlatformUtils.fire.collection("Eventi").document(ev.id).delete();
  }

  void _readEvents(DateTime day) async {
    //TODO query
    DateTime parsedDate = Utils.formatDate(day);
    List<Event> l = List();
    var documents = await PlatformUtils.fire.collection("Eventi").getDocuments();
    for (var document in documents.documents) {
      if (document != null && document.exists) {
        l.add(Event.fromMap(document.documentID, document.data));
      }
    }
    setState(() {
      _events[parsedDate] = l;
    });
  }

      //METODI DI UTILITY
  String getTitle(Event e){
    return e.title;
  }


}