import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';

part 'history_event_list_state.dart';

class HistoryEventListCubit extends Cubit<HistoryEventListState> {
  final CloudFirestoreService _databaseRepository;
  List<Event> listEvent = [];
  var streamSub;

  HistoryEventListCubit(this._databaseRepository, int? _selectedStatus) :
        super(HistoryLoading(_selectedStatus)){
    streamSub = _databaseRepository.eventsHistory().listen((historyEventsList) { //TODO null?
      evaluateEventsMap(historyEventsList);
    });
  }

  void evaluateEventsMap(List<Event> _events){
    Map<int, List<Event>> eventsMap =  {};
    if(_events != null){
      _events.forEach((singleEvent) {
        if(eventsMap[singleEvent.status]==null) eventsMap[singleEvent.status] = [];
        eventsMap[singleEvent.status]!.add(singleEvent);
      });
    }
    emit(state.assign(eventsMap: eventsMap));
  }

  void onStatusSelect(int status) {
    if(listEvent.isNotEmpty){
      Map<int, List<Event>> eventsMap =  Map.from(state.eventsMap);
      eventsMap[state.selectedStatus] = listEvent;
      listEvent = [];
      emit(state.assign(eventsMap: eventsMap));
    }
    emit(state.assign(selectedStatus: status));
  }

  void filterHistoryEvent(Event e, Map<String,bool> categorySelected, bool filterStartDate, bool filterEndDate){
    Map<int, List<Event>> eventsMap =  Map.from(state.eventsMap);
    if(listEvent.isEmpty) listEvent =  state.eventsMap[state.selectedStatus]!;
    eventsMap[state.selectedStatus] = listEvent.where((event) => event.isFilteredEvent(e, categorySelected, filterStartDate, filterEndDate)).toList();
    emit(state.assign(eventsMap: eventsMap));
  }

  void clearFilter(){
    if(listEvent.isNotEmpty){
      Map<int, List<Event>> eventsMap =  Map.from(state.eventsMap);
      eventsMap[state.selectedStatus] = listEvent;
      listEvent = [];
      emit(state.assign(eventsMap: eventsMap));
    }
  }

  @override
  Future<dynamic> close() {
    streamSub.cancel();
    return super.close();
  }
}
