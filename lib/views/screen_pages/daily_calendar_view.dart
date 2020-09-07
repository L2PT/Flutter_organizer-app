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
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/daily_calendar/daily_calendar_cubit.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/plugins/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';

//HANDLE cambia questa costante per modifcare la grandezza degli eventi
const double minEventHeight = 60.0;

class DailyCalendar extends StatelessWidget {
  final DateTime day;

  DailyCalendar([this.day, Key key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var repository = RepositoryProvider.of<CloudFirestoreService>(context);
    var account = BlocProvider
        .of<AuthenticationBloc>(context)
        .account;
    var calendarController = CalendarController();
    var _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
    );
    Map<DateTime, List> _events;
    double _gridHourHeight;
    int _gridHourSpan;
    List _selectedEvents;
    DateTime _selectedDay;

    List<Widget> _buildBack(int length) {
      double barHourHeight = _gridHourHeight / 2;
      return List.generate(length, (i) {
        int n = ((i) * _gridHourSpan) + Constants.MIN_WORKTIME;
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

    List<Widget> _buildFront() {
      List<Widget> r = new List<Widget>();
      double barHourHeight = _gridHourHeight / 2;
      DateTime base = new DateTime(1990, 1, 1, Constants.MIN_WORKTIME, 0, 0);
      DateTime top = new DateTime(1990, 1, 1, Constants.MAX_WORKTIME, 0, 0);

      //SE gridHour == 0 => Evento dura tutto il giorno
      if (_gridHourSpan == 0) {
        r.add(SizedBox(height: 5));
        r.add(
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: Text("Incarico per tutto il giorno", style: subtitle.copyWith(fontSize: 18,),),)
                ]
            )
        );
        r.add(
            Row(children: <Widget>[
              Expanded(
                  flex: 8,
                  child: cardEvent(
                    event: _selectedEvents[0],
                    hourHeight: 120,
                    hourGridSpan: 0,
                    onTapAction: (event)=> PlatformUtils.navigator(context, event),
                    buttonArea: null,
                    dateView: true,
                  )
              ),
            ])
        );
      } else {
        r.add(SizedBox(height: barHourHeight));
        _selectedEvents.forEach((e) {
          r.add(SizedBox(
              height: ((context.bloc<DailyCalendarCubit>().minDailyHour(e.start) - (base.hour * 60 + base.minute)) / 60) / _gridHourSpan * _gridHourHeight));
          r.add(
              Row(children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(right: 40),
                      height: ((context.bloc<DailyCalendarCubit>().maxDailyHour(e.end) - context.bloc<DailyCalendarCubit>().minDailyHour(e.start)) / 60) / _gridHourSpan * _gridHourHeight,
                      child: account.supervisor ? Icon(Status.getIcon(e.status), color: black) : Container(),
                    )
                ),
                Expanded(
                    flex: 8,
                    child: cardEvent(
                      event: e,
                      hourGridSpan: _gridHourSpan,
                      hourHeight: _gridHourHeight,
                      selectedDay: _selectedDay,
                      onTapAction: (event)=> PlatformUtils.navigator(context, event),
                      buttonArea: null,
                      dateView: false,
                    )
                ),
              ])
          );
          int newBaseMinutes = context.bloc<DailyCalendarCubit>().maxDailyHour(e.end);
          base = TimeUtils.truncateDate(base, "day").add(
              Duration(hours: (newBaseMinutes / 60).toInt(), minutes: (newBaseMinutes % 60).toInt()));
        });
        r.add(SizedBox(height: (((top.hour * 60 + top.minute) - (base.hour * 60 + base.minute)) / 60) / _gridHourSpan *
            _gridHourHeight));
      }
      return r;
    }
    //--EVENT LIST
    Widget _buildEventList() {
      return ListView(
        //shrinkWrap: true,
        children: <Widget>[
          Stack(
              children: <Widget>[
                _gridHourSpan == 0 ? Container() :
                Column(
                    children: _buildBack(((Constants.MAX_WORKTIME - Constants.MIN_WORKTIME + 1) / _gridHourSpan)
                        .toInt()) //16 sono le ore della griglia
                )
                , Column(
                    children: _buildFront()
                ),
              ]
          )
        ],
      );
    }



    Widget _buildTableCalendarWithBuilders(CalendarController _calendarController, Map<DateTime, List> _events,
        DateTime _selectedDay, AnimationController _animationController) {
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
              opacity: Tween(begin: 0.0, end: 1.0).animate(
                  _animationController),
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
                  child: Text(
                      '${date.day}',
                      style: const TextStyle(fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                          fontSize: 18)
                  ),
                ),
              ),
            );
          },
          todayDayBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: grey_light,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(child: Text(
                  '${date.day}',
                  style: const TextStyle(fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontSize: 18)
              ),
              ),
            );
          },
          holidayDayBuilder: (context, date, _) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(child: Text(
                  '${date.day}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: white, fontSize: 18)
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
                  child: _buildEventsMarker(date, events, _calendarController),
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
            }
            return children;
          },
        ),
        onDaySelected: (date, events) {
          context.bloc<DailyCalendarCubit>().onDaySelected(date, events);
          _animationController.forward(from: 0.0);
        },
        onVisibleDaysChanged: context.bloc<DailyCalendarCubit>().onVisibleDaysChanged,
        selectNext: () {
          context.bloc<MobileBloc>().add(NavigateEvent(Constants.monthlyCalendarRoute, _selectedDay));
        },
        selectPrevious: () {},
      );
    }

    Widget buildDailyEventCalendar = Column(
        mainAxisSize: MainAxisSize.max,
        children:
        <Widget>[
          _buildTableCalendarWithBuilders(calendarController, _events, this.day, _animationController),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ]);

    return new BlocProvider(
        create: (_) => DailyCalendarCubit(repository, day, account),
        child: Material(
            elevation: 12.0,
            borderRadius: new BorderRadius.only(
                topLeft: new Radius.circular(16.0),
                topRight: new Radius.circular(16.0)),
            child:
            BlocBuilder<DailyCalendarCubit, DailyCalendarState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                if (state is DailyCalendarReady) {
                  _selectedDay = state.selectedDay;
                  _events = state.events;
                  _gridHourSpan = state.gridHourSpan;
                  _gridHourHeight = state.gridHourHeight;
                  _selectedEvents = state.events[state.selectedDay];
                  _animationController.forward();
                  return buildDailyEventCalendar;
                } else
                  return LoadingScreen();
              },
            )
        ));

  }
}


Widget _buildEventsMarker(DateTime date, List events, CalendarController _calendarController) {
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
