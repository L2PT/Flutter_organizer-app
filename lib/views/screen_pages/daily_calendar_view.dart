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
import 'package:loading/loading.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/daily_calendar/daily_calendar_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/plugins/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';
class DailyCalendar extends StatefulWidget {
  final DateTime day;
  final Account operator;

  DailyCalendar([this.day, this.operator, Key key]) : super(key: key);

  @override
  _DailyCalendarViewState createState() => _DailyCalendarViewState(day, operator);
}

class _DailyCalendarViewState extends State<DailyCalendar> with TickerProviderStateMixin {

    final DateTime day;
    final Account operator;

    _DailyCalendarViewState(this.day, this.operator);

  @override
  Widget build(BuildContext context) {
    CloudFirestoreService repository = RepositoryProvider.of<CloudFirestoreService>(context);
    Account account = BlocProvider.of<AuthenticationBloc>(context).account;

    Widget content = Column(
        mainAxisSize: MainAxisSize.max,
        children:
        <Widget>[
          _rowCalendar(this),
          const SizedBox(height: 8.0),
          _verticalEventsGrid()
        ]);

    return new BlocProvider(
        create: (_) => DailyCalendarCubit(repository, account, operator, day),
        child: Material(
            elevation: 12.0,
            borderRadius: new BorderRadius.only(
                topLeft: new Radius.circular(16.0),
                topRight: new Radius.circular(16.0)),
            child: content
    ));
  }
}

class _rowCalendar extends StatelessWidget {
  var _animationController;

  _rowCalendar(_DailyCalendarViewState ticker){
    _animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: ticker);
  }

  @override
  Widget build(BuildContext context) {

    Widget eventsMarker(DateTime date, List events) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: !context.bloc<DailyCalendarCubit>().calendarController.isSelected(date) ?
        context.bloc<DailyCalendarCubit>().calendarController.isToday(date) ?
              Colors.brown[300] :
            Colors.blue[400] :
          Colors.brown[500],
        ),
        width: 16.0,
        height: 16.0,
        child: Center(
          child: Text('${events.length}', style: TextStyle().copyWith(color: Colors.white, fontSize: 12.0,),
          ),
        ),
      );
    }

    Widget holidaysMarker = Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );

    return BlocBuilder<DailyCalendarCubit, DailyCalendarState>(
      buildWhen: (previous, current) => (previous.runtimeType) != (current.runtimeType) ||
          previous.eventsMap != current.eventsMap,
      builder: (context, state) {
        return TableCalendar(
          locale: 'it_IT',
          calendarController: context.bloc<DailyCalendarCubit>().calendarController,
          events: state.eventsMap,
          initialCalendarFormat: CalendarFormat.week,
          formatAnimation: FormatAnimation.slide,
          startingDayOfWeek: StartingDayOfWeek.monday,
          availableGestures: AvailableGestures.horizontalSwipe,
          availableCalendarFormats: {CalendarFormat.week: ''},
          initialSelectedDay: state.selectedDay,
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
                child: Center(child:
                  Text( '${date.day}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333), fontSize: 18)
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
                child: Center(child:
                  Text( '${date.day}', style: const TextStyle(fontWeight: FontWeight.bold, color: white, fontSize: 18)
                ),
                ),
              );
            },
            markersBuilder: (context, date, events, holidays) {
              final children = <Widget>[];
              if (events.isNotEmpty && false) {
                children.add(
                  Positioned(right: 1, bottom: 1, child: eventsMarker(date, events)),
                );
              }
              if (holidays.isNotEmpty && false) {
                children.add(
                  Positioned(right: -2, top: -2, child: holidaysMarker),
                );
              }
              return children;
            },
          ),
          onDaySelected: (date, events) { context.bloc<DailyCalendarCubit>().onDaySelected(date); },
          onVisibleDaysChanged: context.bloc<DailyCalendarCubit>().onVisibleDaysChanged,
          selectNext: () { context.bloc<MobileBloc>().add(NavigateEvent(Constants.monthlyCalendarRoute, context.bloc<DailyCalendarCubit>().state.selectedDay)); },
          selectPrevious: () {},
        );
      },
    );
  }

}

class _verticalEventsGrid extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Account account = BlocProvider
        .of<AuthenticationBloc>(context)
        .account;
    int gridHourSpan;
    double gridHourHeight;

    int _backGridLength;
    double _barHourHeight;
    DateTime _base;
    DateTime _top;

    List<Widget> backGrid() =>
        List.generate(_backGridLength, (i) {
          int n = ((i) * gridHourSpan) + Constants.MIN_WORKTIME;
          return Row(children: <Widget>[Expanded(
              flex: 2,
              child: Container(
                  padding: EdgeInsets.only(left: 20),
                  height: gridHourHeight,
                  child: Center(
                    child: Text("$n:00", style: TextStyle(color: grey_dark),),)
              )
          ),
            Expanded(
                flex: 8,
                child: Column(children: <Widget>
                [Container(
                      height: _barHourHeight,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 4, color: grey_light2),
                        ),
                      )
                  ), Container(
                    height: _barHourHeight,
                  )
                ]
                )
            ),
          ]
          );
        }).toList();

    List<Widget> frontEventList() =>
        (gridHourSpan == 0) ?
        //evento che dura tutto il giorno
        <Widget>[
          SizedBox(height: 5),
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 10, bottom: 10),
                  child: Text("Incarico per tutto il giorno", style: subtitle.copyWith(fontSize: 18,),),)
              ]
          ),
          Row(children: <Widget>[
            Expanded(
                flex: 8,
                child: cardEvent(
                  event: (context
                      .bloc<DailyCalendarCubit>()
                      .state as DailyCalendarReady).selectedEvents()[0],
                  hourHeight: 120,
                  gridHourSpan: 0,
                  onTapAction: (event) => PlatformUtils.navigator(context, event),
                  buttonArea: null,
                  dateView: true,
                )
            ),
          ])
        ] :
        //lista di eventi
        <Widget>[
          SizedBox(height: _barHourHeight),
          ...(context
              .bloc<DailyCalendarCubit>()
              .state as DailyCalendarReady).selectedEvents().map((event) {
            List <Widget> element = <Widget>[
              SizedBox(height: ((DailyCalendarCubit.minDailyHour(event.start, context
                  .bloc<DailyCalendarCubit>()
                  .state
                  .selectedDay) -
                  (_base.hour * 60 + _base.minute)) / 60) / gridHourSpan * gridHourHeight),
              Row(children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(right: 40),
                      height: ((DailyCalendarCubit.maxDailyHour(event.end, context
                          .bloc<DailyCalendarCubit>()
                          .state
                          .selectedDay) -
                          DailyCalendarCubit.minDailyHour(event.start, context
                              .bloc<DailyCalendarCubit>()
                              .state
                              .selectedDay)) / 60) / gridHourSpan * gridHourHeight,
                      child: account.supervisor ? Icon(Status.getIcon(event.status), color: black) : Container(),
                    )
                ),
                Expanded(
                  flex: 8,
                  child: cardEvent(
                    event: event,
                    dateView: false,
                    hourHeight: gridHourHeight,
                    gridHourSpan: gridHourSpan,
                    selectedDay: context
                        .bloc<DailyCalendarCubit>()
                        .state
                        .selectedDay,
                    onTapAction: (event) => PlatformUtils.navigator(context, event),
                  ),
                ),
              ])
            ];
            int newBaseMinutes = DailyCalendarCubit.maxDailyHour(event.end, context
                .bloc<DailyCalendarCubit>()
                .state
                .selectedDay);
            _base = TimeUtils.truncateDate(_base, "day").add(
                Duration(hours: newBaseMinutes ~/ 60, minutes: (newBaseMinutes % 60).toInt()));
            return element;
          }).expand((i) => i).toList(),
          SizedBox(height: (((_top.hour * 60 + _top.minute) - (_base.hour * 60 + _base.minute)) / 60) / gridHourSpan *
              gridHourHeight)
        ];


    return BlocBuilder<DailyCalendarCubit, DailyCalendarState>(
        buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          return !(state is DailyCalendarReady) ? Center(child: CircularProgressIndicator()) :
          ListView(
            shrinkWrap: true,//TODO remove and fix the viewport
            children: <Widget>[
              Stack(
                  children: <Widget>[
                    BlocBuilder<DailyCalendarCubit, DailyCalendarState>(
                        buildWhen: (previous, current) => previous != current,
                        builder: (context, state) {
                          gridHourSpan = state.gridHourSpan;
                          gridHourHeight = state.gridHourHeight;
                          _backGridLength =
                              ((Constants.MAX_WORKTIME - Constants.MIN_WORKTIME + 1) / gridHourSpan).toInt();
                          _barHourHeight = gridHourHeight / 2;
                          return state.gridHourSpan == 0 ? Container(height: 20,) :
                          Column(
                              children: backGrid()
                          );
                        }
                    ),
                    BlocBuilder<DailyCalendarCubit, DailyCalendarState>(
                        buildWhen: (previous, current) => previous != current,
                        builder: (context, state) {
                          _base = new DateTime(1990, 1, 1, Constants.MIN_WORKTIME, 0, 0);
                          _top = new DateTime(1990, 1, 1, Constants.MAX_WORKTIME, 0, 0);
                          return (state as DailyCalendarReady)
                              .selectedEvents()
                              .length <= 0 ? Container(height: 20) :
                          Column(
                              children: frontEventList()
                          );
                        }
                    )
                  ]
              )
            ],
          );
        }
    );
  }
}