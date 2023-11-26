import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/plugins/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/date_utils.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'daily_calendar_state.dart';

class DailyCalendarCubit extends Cubit<DailyCalendarState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  final Account? operator;
  late List<Event> _events;
  CalendarController calendarController = new CalendarController();

  DailyCalendarCubit(this._databaseRepository, this._account, this.operator, DateTime? _selectedDay) :
        super(DailyCalendarLoading(_selectedDay)){
    loadMoreData(_selectedDay);
  }

  void onDaySelected(DateTime day) {
    if(calendarController.visibleDays.toString() != state.subscribedDays.toString())
      loadMoreData(TimeUtils.truncateDate(calendarController.visibleDays.first, "day"),TimeUtils.truncateDate(calendarController.visibleDays.last, "day").add(new Duration(days: 1)));
    day = TimeUtils.truncateDate(day, "day");
    if(Constants.debug) print("$day selected");
    if(state is DailyCalendarLoading) state.selectedDay = day;
    else emit(DailyCalendarReady((state as DailyCalendarReady).eventsMap, day, state.subscribedDays));
  }

  void loadMoreData([DateTime? start, DateTime? end]){
    _databaseRepository.subscribeEventsByOperator([(operator??_account).id], statusEqualOrAbove: _account.supervisor? EventStatus.Refused : EventStatus.Accepted,
        from: TimeUtils.truncateDate(start??DateTime.now().subtract(new Duration(days: 7)), "day"),
        to: end?.add(new Duration(days: 1))??TimeUtils.truncateDate((start??DateTime.now()).add(new Duration(days: 7)), "day")).listen((eventsList) {
      _events = eventsList;
      evaluateEventsMap(start??TimeUtils.truncateDate(calendarController.visibleDays.first, "day"), end??TimeUtils.truncateDate(calendarController.visibleDays.last, "day").add(new Duration(days: 1)));
    });
  }

  void evaluateEventsMap(DateTime first, DateTime last){
    Map<DateTime, List<Event>> eventsMap = {};
    first = TimeUtils.truncateDate(first,"day");
    last = TimeUtils.truncateDate(last,"day").add(Duration(hours: 23));
    _events.forEach((singleEvent) {
     if (singleEvent.isBetweenDate(first, last)) {
       int diff = singleEvent.end.difference(singleEvent.start).inDays;
       for(var i=0;i<=diff;i++){
         DateTime dateIndex = TimeUtils.truncateDate(singleEvent.start.add(new Duration(days: i)), "day");
         if(eventsMap[dateIndex]==null) eventsMap[dateIndex]=[];
         eventsMap[dateIndex]!.add(singleEvent);
       }
     }
    });
    emit(DailyCalendarReady(eventsMap, TimeUtils.truncateDate(state.selectedDay, "day"), calendarController.visibleDays));
  }

  double calcWidgetHeightInGrid({DateTime? start, DateTime? end, int? firstWorkedMinute, int? lastWorkedMinute}) {
    return DateUtils.calcWidgetHeightInGrid(state.selectedDay, state.gridHourSpan, state.gridHourHeight,
        start: start, end: end, firstWorkedMinute: firstWorkedMinute , lastWorkedMinute: lastWorkedMinute );
  }


}
