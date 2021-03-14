import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final CloudFirestoreService _databaseRepository;
  var streamSub;

  HistoryCubit(this._databaseRepository, int? _selectedStatus) :
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
    emit(state.assign(selectedStatus: status));
  }

  @override
  Future<dynamic> close() {
    streamSub.cancel();
    return super.close();
  }
}
