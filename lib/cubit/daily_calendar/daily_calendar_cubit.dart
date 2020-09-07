import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'daily_calendar_state.dart';

class DailyCalendarCubit extends Cubit<DailyCalendarState> {
  final CloudFirestoreService _databaseRepository;
  DateTime _selectedDay;
  final Account _account;

  DailyCalendarCubit(this._databaseRepository,this._selectedDay, this._account)
      : assert(_databaseRepository != null),
        super(DailyCalendarLoading()){
    getEventsDay(this._selectedDay, this._account);
  }

  void getEventsDay(DateTime day, Account _account) async {
    Map<DateTime, List> eventsMap = {};
    List<Event> events = [];
    _databaseRepository.subscribeEventsByOperator(_account.id).listen((eventsList) {
      eventsList.forEach((singleEvent){
        if(singleEvent.isBetweenDate(day, day.add(Duration(days: 1)))){
          events.add(singleEvent);
        }
      });
      eventsMap[this._selectedDay] = events;
      emit(DailyCalendarReady(this._selectedDay,eventsMap));
    });
  }

  //This function initialize the variables to show properly the grid behind the events

  void onDaySelected(DateTime day, List events) {
    if(Constants.debug) print("${day} selected");
    DailyCalendarReady state = (this.state as DailyCalendarReady);
    this._selectedDay = TimeUtils.truncateDate(day, "day");
    state.events[this._selectedDay] = events;
    emit(DailyCalendarReady(this._selectedDay,state.events));
  }

  int minDailyHour(DateTime start) {
    DailyCalendarReady state = (this.state as DailyCalendarReady);
    return state.minDailyHour(start);
  }

  int maxDailyHour(DateTime end) {
    DailyCalendarReady state = (this.state as DailyCalendarReady);
    return state.maxDailyHour(end);
  }

  void onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {}

}
