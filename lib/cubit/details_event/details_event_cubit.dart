import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/firebase/firebase_messaging.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';

part 'details_event_state.dart';

class DetailsEventCubit extends Cubit<DetailsEventState> {
  final BuildContext context;
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  final Event _event;

  DetailsEventCubit(this.context, CloudFirestoreService databaseRepository, Account account, Event event) :
      assert(databaseRepository != null && account != null && event != null),
      _databaseRepository = databaseRepository, _account = account, _event = event,
      super(DetailsEventState(event)) {
    if(state.event.operator["id"] == _account.id && state.event.status < Status.Seen){
      state.event.status = Status.Seen;
      emit(state);
      _databaseRepository.updateEventField(state.event.id, "Stato", Status.Seen);
    }
  }

  void endEventAndNotify() {
    state.event.status = Status.Ended;
    emit(state);
    _databaseRepository.updateEventField(state.event.id, "Stato", Status.Ended);
    FirebaseMessagingService.sendNotification(token:Account.fromMap("", state.event.supervisor).token, title: "${_account.surname} ${_account.name} ha terminato il lavoro \"${state.event.title}\"");
  }

  void deleteEvent() {
    Navigator.pop(context);
  }

  void modifyEvent() {
    Navigator.pop(context);
    context.bloc<MobileBloc>().add(NavigateEvent(Constants.createEventViewRoute,_event));
  }

}
