import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'monthly_calendar_state.dart';

class MonthlyCalendarCubit extends Cubit<MonthlyCalendarState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  final Account? operator;
  late List<Event> _events;
  late CalendarController calendarController;

  MonthlyCalendarCubit(this._databaseRepository, this._account, this.operator, DateTime? _selectedMonth) :
    super(MonthlyCalendarLoading(_selectedMonth)){
    calendarController = new CalendarController();
    if(_account.supervisor){
      _databaseRepository.eventsByOperatorNewOrAbove((operator??_account).id).listen((eventsList) {
        _events = eventsList;
        evaluateEventsMap(TimeUtils.truncateDate(_selectedMonth??DateTime.now(), "month"), TimeUtils.truncateDate(_selectedMonth??DateTime.now(), "month").add(new Duration(days: 30)));
      });
    }else{
      _databaseRepository.eventsByOperatorAcceptedOrAbove((operator??_account).id).listen((eventsList) {
        _events = eventsList;
        evaluateEventsMap(TimeUtils.truncateDate(_selectedMonth??DateTime.now(), "month"), TimeUtils.truncateDate(_selectedMonth??DateTime.now(), "month").add(new Duration(days: 30)));
      });
      }
  }

  void evaluateEventsMap(DateTime first, DateTime last){
    Map<DateTime, List<Event>> eventsMap = {};
    _events.forEach((singleEvent) {
      for(int i in List<int>.generate(max(1,singleEvent.end.difference(singleEvent.start).inDays), (i) => i + 1)){
        DateTime month = TimeUtils.truncateDate(singleEvent.start, "month");
        DateTime dateIndex = month.toUtc().add(Duration(days:singleEvent.start.day+i-2)).add(month.timeZoneOffset);
        if(eventsMap[dateIndex]==null) eventsMap[dateIndex] = [];
        eventsMap[dateIndex]!.add(singleEvent);
      }
    });
    emit(MonthlyCalendarReady(eventsMap, state.selectedMonth));
  }

}
