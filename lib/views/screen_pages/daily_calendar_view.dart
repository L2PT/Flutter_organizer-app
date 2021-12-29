/*
THIS IS THE MAIN PAGE OF THE OPERATOR
-l'appBar contiene menu a sinistra, titolo al centro
-in alto c'è una riga di giorni della settimana selezionabili
-(R)al centro e in basso c'è una grglia oraria dove sono rappresentati gli eventi dell'operatore corrente del giorno selezionato in alto
-(O)al centro e in basso c'è una grglia oraria dove sono rappresentati i propri eventi del giorno selezionato in alto
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/daily_calendar/daily_calendar_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/plugins/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';
import 'package:venturiautospurghi/views/widgets/no_events_widget.dart';

class DailyCalendar extends StatefulWidget {
  final DateTime? day;
  final Account? operator;

  DailyCalendar([this.day, this.operator]);

  @override
  _DailyCalendarViewState createState() => _DailyCalendarViewState(day, operator);
}

class _DailyCalendarViewState extends State<DailyCalendar> with TickerProviderStateMixin {
    final DateTime? _day;
    final Account? _operator;

    _DailyCalendarViewState(this._day, this._operator);

  @override
  Widget build(BuildContext context) {
    CloudFirestoreService repository = context.read<CloudFirestoreService>();
    Account account = context.select((AuthenticationBloc bloc)=>bloc.account!);

    Widget content = Column(
        mainAxisSize: MainAxisSize.max,
        children:
        <Widget>[
          _rowCalendar(this),
          const SizedBox(height: 8.0),
          _verticalEventsGrid(this)
        ]);

    return new BlocProvider(
        create: (_) => DailyCalendarCubit(repository, account, _operator, _day),
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
  var _animation;

  _rowCalendar(_DailyCalendarViewState ticker){
    _animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: ticker);
    _animation = Tween(begin: 0.0, end: 1.0,).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    _animationController.forward();

    Widget eventsMarker(DateTime date, List events) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: !context.read<DailyCalendarCubit>().calendarController.isSelected(date) ?
        context.read<DailyCalendarCubit>().calendarController.isToday(date) ?
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
          calendarController: context.read<DailyCalendarCubit>().calendarController,
          events: state.eventsMap,
          initialCalendarFormat: CalendarFormat.week,
          formatAnimation: FormatAnimation.slide,
          startingDayOfWeek: StartingDayOfWeek.monday,
          availableGestures: AvailableGestures.horizontalSwipe,
          availableCalendarFormats: {CalendarFormat.week: ''},
          initialSelectedDay: state.selectedDay,
          builders: CalendarBuilders(
            selectedDayBuilder: (context, date, _) {
              return  FadeTransition(
                opacity: _animation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: black,
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Center(
                    child: Text(
                        '${date.day}',
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            color: white,
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
          onDaySelected: (date, events) {
            context.read<DailyCalendarCubit>().onDaySelected(date);
            //_animationController.forward(from: 0.0);
           },//    if(state is DailyCalendarReady)
          selectMonthCalendar: () {
            context.read<MobileBloc>().add(NavigateEvent(Constants.monthlyCalendarRoute, {'month': context.read<DailyCalendarCubit>().state.selectedDay, 'operator' : context.read<DailyCalendarCubit>().operator}));
            _animationController.dispose();
          },
        );
      },
    );
  }

}

class _verticalEventsGrid extends StatelessWidget {
  var _animationController;

  _verticalEventsGrid(_DailyCalendarViewState ticker) {
    _animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: ticker);
  }

    @override
  Widget build(BuildContext context) {
    Account account = context.read<AuthenticationBloc>().account!;
    int backGridHourSpan = context.select((DailyCalendarCubit cubit) => cubit.state.gridHourSpan);
    double gridHourHeight = context.select((DailyCalendarCubit cubit) => cubit.state.gridHourHeight);
    bool allDayEvent = context.select((DailyCalendarCubit cubit) => cubit.state.allDayEvent);

    late int _backGridLength;
    late double _barHourHeight;
    late DateTime _base;
    late DateTime _top;

    List<Widget> backGrid() =>
        List.generate(_backGridLength, (i) {
          int n = ((i) * backGridHourSpan) + Constants.MIN_WORKTIME;
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
      (backGridHourSpan == 0 && allDayEvent) ?
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
                child: CardEvent(
                  event: (context.read<DailyCalendarCubit>().state as DailyCalendarReady).selectedEvents()[0],
                  height: gridHourHeight,
                  externalBorder: account.supervisor,
                  showEventDetails: true,
                  onTapAction: (event) => PlatformUtils.navigator(context,Constants.detailsEventViewRoute, event),

                )
            ),
          ])
        ] : (backGridHourSpan == 0) ?
        //lista di eventi continua
        <Widget>[
          SizedBox(height: 5),
          ...(context
              .read<DailyCalendarCubit>()
              .state as DailyCalendarReady).selectedEvents().map((event) => Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: Row(children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(right: 40),
                      height: gridHourHeight,
                      child: account.supervisor ? Icon(EventStatus.getIcon(event.status), color: black) : Container(),
                    )
                ),
                Expanded(
                  flex: 8,
                  child: CardEvent(
                    event: event,
                    height: gridHourHeight,
                    externalBorder: account.supervisor,
                    showEventDetails: true,
                    onTapAction: (event) => PlatformUtils.navigator(context,Constants.detailsEventViewRoute, event),
                  ),
                ),
              ])))
        ] :
        //lista di eventi spaziati
        <Widget>[
          SizedBox(height: _barHourHeight),
          ...(context
              .read<DailyCalendarCubit>()
              .state as DailyCalendarReady).selectedEvents().map((event) {
            List <Widget> element = <Widget>[
              SizedBox( height: context.read<DailyCalendarCubit>().calcWidgetHeightInGrid(firstWorkedMinute: _base.hour * 60 + _base.minute, end: event.start)),
              Row(children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(right: 40),
                      height: context.read<DailyCalendarCubit>().calcWidgetHeightInGrid(start: event.start, end: event.end),
                      child: account.supervisor ? Icon(EventStatus.getIcon(event.status), color: black) : Container(),
                    )
                ),
                Expanded(
                  flex: 8,
                  child: CardEvent(
                    event: event,
                    height: context.read<DailyCalendarCubit>().calcWidgetHeightInGrid(start: event.start, end: event.end),
                    externalBorder: account.supervisor,
                    onTapAction: (event) => PlatformUtils.navigator(context,Constants.detailsEventViewRoute, event),
                  ),
                ),
              ])
            ];
            int newBaseMinutes = DailyCalendarCubit.getLastDailyWorkedMinute(event.end, context.read<DailyCalendarCubit>().state.selectedDay);
            _base = TimeUtils.truncateDate(_base, "day").add(
                Duration(hours: newBaseMinutes ~/ 60, minutes: (newBaseMinutes % 60).toInt()));
            return element;
          }).expand((i) => i).toList(),
          SizedBox(height: (((_top.hour * 60 + _top.minute) - (_base.hour * 60 + _base.minute)) / 60) / backGridHourSpan *
              gridHourHeight)
        ];


    return BlocBuilder<DailyCalendarCubit, DailyCalendarState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (!(state is DailyCalendarReady))
            return Center(child: CircularProgressIndicator());
          if((state as DailyCalendarReady).selectedEvents().isEmpty)
            return Padding(
              padding: EdgeInsets.all(20),
              child: EmptyEvent(
                onPressedFunction: () {
                    context.read<MobileBloc>().add( NavigateEvent(Constants.monthlyCalendarRoute, {'month': context.read<DailyCalendarCubit>().state.selectedDay, 'operator' : context.read<DailyCalendarCubit>().operator}));
                    _animationController.dispose();
                },
                titleMessage: 'Nessun intervento in programma per questa data',
                subtitleMessage: "Controlla i tuoi incarichi",
            ));

          _backGridLength = backGridHourSpan == 0 ? 0 : (Constants.MAX_WORKTIME - Constants.MIN_WORKTIME + 1) ~/ backGridHourSpan;
          _barHourHeight = gridHourHeight / 2;
          _base = new DateTime(1990, 1, 1, Constants.MIN_WORKTIME, 0, 0);
          _top = new DateTime(1990, 1, 1, Constants.MAX_WORKTIME, 0, 0);
          return Expanded( child: ListView(
                  children: <Widget>[
                    Stack(
                        children: <Widget>[
                          backGridHourSpan == 0 ? Container(height: 20) :
                          Column(
                            mainAxisSize: MainAxisSize.max,
                              children: backGrid()
                          ),
                          state.selectedEvents().length <= 0 ? Container(height: 20) :
                          Column(
                              mainAxisSize: MainAxisSize.max,
                              children: frontEventList()
                          )
                        ])
                  ]));
        });
  }
}