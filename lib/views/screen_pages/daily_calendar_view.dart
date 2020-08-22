/*
THIS IS THE MAIN PAGE OF THE OPERATOR
-l'appBar contiene menu a sinistra, titolo al centro
-in alto c'è una riga di giorni della settimana selezionabili
-(R)al centro e in basso c'è una grglia oraria dove sono rappresentati gli eventi dell'operatore corrente del giorno selezionato in alto
-(O)al centro e in basso c'è una grglia oraria dove sono rappresentati i propri eventi del giorno selezionato in alto
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/events_bloc/events_bloc.dart';
import 'package:venturiautospurghi/bloc/backdrop_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugin/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'file:///C:/Users/Gio/Desktop/Flutter_organizer-app/lib/views/widgets/splash_screen.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';

//HANDLE cambia questa costante per modifcare la grandezza degli eventi
const double minEventHeight = 60.0;

class DailyCalendar extends StatefulWidget {
  DateTime day;
  DailyCalendar([this.day,Key key]) : super(key: key);

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
  bool ready = false;
  Account account;

  @override
  void initState() {
    super.initState();
    account = BlocProvider.of<AuthenticationBloc>(context).account;
    _selectedDay = widget.day!=null?widget.day:TimeUtils.truncateDate(DateTime.now(), "day");
    _events = Map();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
    _gridHourHeight = minEventHeight;
    _gridHourSpan = 1;
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _calendarController?.dispose();
    super.dispose();
  }

  //MAIN BUILEDER METHODS
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          if (state is Loaded) {
            //get data
            BlocProvider.of<EventsBloc>(context).add(FilterEventsByDay(_selectedDay));
            ready = true;
          }else if(state is Filtered && ready){
            _events[state.selectedDay] = state.events;
            initList();
            return Material(
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
          return LoadingScreen();
        }
    );
  }

  //--CALENDAR
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'it_IT',
      calendarController: _calendarController,
      events: _events,
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
                          color: black,
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
        holidayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 2),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(child:Text(
                '${date.day}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: white,fontSize: 18)
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
      selectNext: () {
        Utils.NavigateTo(context,global.Constants.monthlyCalendarRoute, _selectedDay);
      },
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
      //shrinkWrap: true,
        children: <Widget>[
          Stack(
              children: <Widget>[
                _gridHourSpan==0?Container():
                Column(
                    children: _buildBack(((global.Constants.MAX_WORKHOUR_SPAN-global.Constants.MIN_WORKHOUR_SPAN+1)/_gridHourSpan).toInt()) //16 sono le ore della griglia
                )
                ,Column(
                    children: _buildFront()
                ),
              ]
          )
        ],
    );
  }

  //This function initialize the variables to show properly the grid behind the events
  void initList() {
    _selectedEvents = _events[_selectedDay] ?? [];
    if(_selectedEvents.length>0) {
      if(_selectedEvents.length == 1 &&
          _selectedEvents[0].start.compareTo(_selectedDay.add(Duration(hours: global.Constants.MIN_WORKHOUR_SPAN)))<=0 &&
          _selectedEvents[0].end.compareTo(_selectedDay.add(Duration(hours: global.Constants.MAX_WORKHOUR_SPAN)))>=0) {
        _gridHourHeight = minEventHeight;
        _gridHourSpan = 0;
      }else{
        //order by start date probably useless since firestore order date automatically
        _selectedEvents.sort((a, b) => a.start.compareTo(b.start));
        //identify minimum duration's event
        int md = 4;
        _selectedEvents.forEach((e) => {
          md = max(0, min(md.toInt(), ((maxDailyHour(e.end) - minDailyHour(e.start)) / 60).toInt()))
        });
        if (md == 0) {
          _gridHourHeight = minEventHeight * 2;
          _gridHourSpan = 1;
        } else {
          int i = 0;
          while (md == (max(pow(2, i), md)))i++;
          md = (min(pow(2, i-1), md));
          _gridHourHeight = minEventHeight;
          _gridHourSpan = md;
        }
      }

    }else{
      _gridHourHeight = minEventHeight;
      _gridHourSpan = 1;
    }
  }

  List<Widget> _buildBack(int length) {
    double barHourHeight = _gridHourHeight / 2;
    return List.generate(length, (i) {
      int n = ((i)*_gridHourSpan) + global.Constants.MIN_WORKHOUR_SPAN;
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
                      bottom: BorderSide(width: 4, color: grey_light2),
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
    DateTime base = new DateTime(1990,1,1,global.Constants.MIN_WORKHOUR_SPAN,0,0);
    DateTime top = new DateTime(1990,1,1,global.Constants.MAX_WORKHOUR_SPAN,0,0);

    //SE gridHour == 0 => Evento dura tutto il giorno
    if(_gridHourSpan==0){
      r.add(SizedBox(height: 5));
      r.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 10, bottom: 10), child: Text("Incarico per tutto il giorno", style: subtitle.copyWith(fontSize: 18,),),)
                ]
          )
      );
      r.add(
          Row(children: <Widget>[
            Expanded(
                flex: 8,
                child: cardEvent(
                  e:_selectedEvents[0],
                  hourHeight: 120,
                  hourSpan: 0,
                  actionEvent: (ev)=> Utils.PushViewDetailsEvent(context, ev),
                  buttonArea: false,
                  dateView: true,
                )
            ),
          ])
      );
    }else{
      r.add(SizedBox(height: barHourHeight));
      _selectedEvents.forEach((e){
        r.add(SizedBox(height: ((minDailyHour(e.start)-(base.hour*60+base.minute))/60)/_gridHourSpan*_gridHourHeight));
        r.add(
            Row(children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(right: 40),
                    height: ((maxDailyHour(e.end) - minDailyHour(e.start))/60)/_gridHourSpan*_gridHourHeight,
                    child: account.supervisor?Icon(Status.getIcon(e.status),color: black):Container(),
                  )
              ),
              Expanded(
                  flex: 8,
                  child: cardEvent(
                    e:e,
                    hourSpan:_gridHourSpan,
                    hourHeight:_gridHourHeight,
                    selectedDay: _selectedDay,
                    actionEvent: (ev)=> Utils.PushViewDetailsEvent(context, ev),
                    buttonArea: false,
                    dateView: false,
                  )
              ),
            ])
        );
        int newBaseMinutes = maxDailyHour(e.end);
        base = TimeUtils.truncateDate(base, "day").add(Duration(hours: (newBaseMinutes/60).toInt(), minutes: (newBaseMinutes%60).toInt()));
      });
      r.add(SizedBox(height: (((top.hour*60+top.minute)-(base.hour*60+base.minute))/60)/_gridHourSpan*_gridHourHeight));
    }
    return r;
  }

  //METODI DI CALLBACK
  void _onDaySelected(DateTime day, List events) {
    _selectedDay = TimeUtils.truncateDate(day, "day");
    BlocProvider.of<MobileBloc>(context).day = TimeUtils.truncateDate(day, "day");
    BlocProvider.of<EventsBloc>(context).add(FilterEventsByDay(TimeUtils.truncateDate(day, "day")));
  }

  int minDailyHour(DateTime start){
    return (start.day!=_selectedDay.day?global.Constants.MIN_WORKHOUR_SPAN*60:max<int>(global.Constants.MIN_WORKHOUR_SPAN*60,start.hour * 60 + start.minute));
  }
  int maxDailyHour(DateTime end){
    return (end.day!=_selectedDay.day?global.Constants.MAX_WORKHOUR_SPAN*60:min<int>(global.Constants.MAX_WORKHOUR_SPAN*60,end.hour * 60 + end.minute));
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {}


}