import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'monthly_calendar_state.dart';

class MonthlyCalendarCubit extends Cubit<MonthlyCalendarState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  final Account _operator;
  List<Event> _events;
  CalendarController calendarController = new CalendarController();

  MonthlyCalendarCubit(this._databaseRepository, this._account, this._operator, DateTime _selectedMonth)
    : assert(_databaseRepository != null),
    super(MonthlyCalendarLoading(_selectedMonth)){
    _databaseRepository.subscribeEventsByOperator((_operator??_account).id).listen((eventsList) {
      _events = eventsList;
      evaluateEventsMap(calendarController.visibleDays.first, calendarController.visibleDays.last);
    });
  }

  void evaluateEventsMap(DateTime first, DateTime last){
    Map<DateTime, List<Event>> eventsMap;
    List<Event> events = List();
    if(this._events != null){
      _events.forEach((singleEvent) {
        if (singleEvent.isBetweenDate(first, last)) {
          for(int i in List<int>.generate(max(1,singleEvent.end.difference(singleEvent.start).inDays), (i) => i + 1)){
            DateTime month = TimeUtils.truncateDate(singleEvent.start, "month");
            DateTime dateIndex = month.toUtc().add(Duration(days:singleEvent.start.day+i-2)).add(month.timeZoneOffset);
            if(eventsMap[dateIndex]==null)eventsMap[dateIndex]=List();
            eventsMap[dateIndex].add(singleEvent);
          }
        }
      });
    }
    emit(MonthlyCalendarReady(eventsMap, state.selectedMonth));
  }


  void onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    if(state is MonthlyCalendarReady)
      evaluateEventsMap(calendarController.visibleDays.first, calendarController.visibleDays.last);
  }
}
