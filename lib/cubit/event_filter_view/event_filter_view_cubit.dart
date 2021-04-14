import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';

part 'event_filter_view_state.dart';

class EventFilterViewCubit extends Cubit<EventFilterViewState> {
  final CloudFirestoreService _databaseRepository;
  List<Event> listEvent = [];

  EventFilterViewCubit(this._databaseRepository) : super(LoadingEventFilterView()){
    _databaseRepository.subscribeEvents().listen((eventsList) {
      emit(state.assign(eventsList: eventsList));
    });
  }

  void filterEvent(Event e, Map<String,bool> categorySelected, bool filterStartDate, bool filterEndDate){
    List<Event> eventsList =  List.from(state.listEventFiltered);
    if(listEvent.isEmpty) listEvent =  state.listEventFiltered;
    eventsList = listEvent.where((event) => event.isFilteredEvent(e, categorySelected, filterStartDate, filterEndDate)).toList();
    emit(state.assign(eventsList: eventsList));
  }

  void clearFilter(){
    if(listEvent.isNotEmpty){
      List<Event> eventsList =  List.from(state.listEventFiltered);
      eventsList = listEvent;
      listEvent = [];
      emit(state.assign(eventsList: eventsList));
    }
  }

}
