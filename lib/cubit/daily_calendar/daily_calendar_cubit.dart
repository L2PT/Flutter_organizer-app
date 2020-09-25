import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'daily_calendar_state.dart';

class DailyCalendarCubit extends Cubit<DailyCalendarState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  final Account _operator;
  List<Event> _events;
  CalendarController calendarController = new CalendarController();

  DailyCalendarCubit(this._databaseRepository, this._account, this._operator, DateTime _selectedDay)
      : assert(_databaseRepository != null),
        super(DailyCalendarLoading(TimeUtils.truncateDate(_selectedDay??DateTime.now(), "day"))){
    //HOW to listen to stream?
    if(_account.supervisor){
      _databaseRepository.subscribeEventsByOperator((_operator??_account).id).listen((eventsList) {
        _events = eventsList;
        evaluateEventsMap(calendarController.visibleDays.first, calendarController.visibleDays.last);
      });
    }else{
      _databaseRepository.eventsByOperatorAcceptedOrAbove((_operator??_account).id).listen((eventsList) {
        _events = eventsList;
        evaluateEventsMap(calendarController.visibleDays.first, calendarController.visibleDays.last);
      });
    }

  }

  void onDaySelected(DateTime day) {
    day = TimeUtils.truncateDate(day, "day");
    if(Constants.debug) print("$day selected");
    if(state is DailyCalendarLoading) state.selectedDay = day;
    else emit(DailyCalendarReady((state as DailyCalendarReady).eventsMap, day));
  }

  void onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    if(state is DailyCalendarReady)
      evaluateEventsMap(calendarController.visibleDays.first, calendarController.visibleDays.last);
  }

  void evaluateEventsMap(DateTime first, DateTime last){
    Map<DateTime, List<Event>> eventsMap = state.eventsMap;
    if(this._events != null){
     _events.forEach((singleEvent) {
       if (singleEvent.isBetweenDate(first, last)) {
         DateTime dateIndex = TimeUtils.truncateDate(singleEvent.start, "day");
         if(eventsMap[dateIndex]==null)eventsMap[dateIndex]=List();
         eventsMap[dateIndex].add(singleEvent);
       }
     });
   }
    emit(DailyCalendarReady(eventsMap, state.selectedDay));
  }

  static int minDailyHour(DateTime start, DateTime today) {
    return (start.day != today.day ? Constants.MIN_WORKTIME * 60 : max<int>(
        Constants.MIN_WORKTIME * 60, start.hour * 60 + start.minute));
  }

  static int maxDailyHour(DateTime end, DateTime today) {
    return (end.day != today.day ? Constants.MAX_WORKTIME * 60 : min<int>(
        Constants.MAX_WORKTIME * 60, end.hour * 60 + end.minute));
  }

}
