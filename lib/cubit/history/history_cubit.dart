import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final CloudFirestoreService _databaseRepository;
  List<Event> _events;

  HistoryCubit(this._databaseRepository, int _selectedStatus)   : assert(_databaseRepository != null),
        super(HistoryLoading(_selectedStatus)){
    _databaseRepository.eventsHistory().listen((historyEventsList) {
      _events = historyEventsList;
      evaluateEventsMap();
    });
  }

  void evaluateEventsMap(){
    Map<int, List<Event>> eventsMap;
    List<Event> events = List();
    if(this._events != null){
      _events.forEach((singleEvent) {
        if(eventsMap[singleEvent.status]==null)eventsMap[singleEvent.status]=List();
        eventsMap[singleEvent.status].add(singleEvent);
      });
    }
    emit(HistoryReady(state.selectedStatus, eventsMap));
  }

  void onStatusSelect(int status) {
    if(Constants.debug) print("$status selected");
    if(state is HistoryLoading) state.selectedStatus = status;
    else emit(HistoryReady(status,(state as HistoryReady).eventsMap));
  }
}
