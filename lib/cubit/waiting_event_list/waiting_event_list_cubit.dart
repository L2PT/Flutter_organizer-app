import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'waiting_event_list_state.dart';

class WaitingEventListCubit extends Cubit<WaitingEventListState> {
  final CloudFirestoreService _databaseRepository;

  WaitingEventListCubit(this._databaseRepository)
      : assert(_databaseRepository != null),
        super(LoadingEvents()){
    getEvents();
  }

  void getEvents() async {
    List<Event> events = await _databaseRepository.getEvents();
    emit(ReadyEvents(events));
  }

}
