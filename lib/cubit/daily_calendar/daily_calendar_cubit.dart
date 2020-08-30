import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';

part 'daily_calendar_state.dart';

class DailyCalendarCubit extends Cubit<DailyCalendarState> {
  final CloudFirestoreService _databaseRepository;
  final DateTime _selectedDay;
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


}
