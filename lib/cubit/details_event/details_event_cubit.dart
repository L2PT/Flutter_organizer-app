import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_messaging_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

part 'details_event_state.dart';

class DetailsEventCubit extends Cubit<DetailsEventState> {
  final BuildContext context;
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  final Event _event;

  DetailsEventCubit(this.context, CloudFirestoreService databaseRepository, Account account, Event event) :
      _databaseRepository = databaseRepository, _account = account, _event = event,
      super(DetailsEventState(event)) {
    if(state.event.operator!.id == _account.id && state.event.status < EventStatus.Seen){
      emit(state.changeStatus(EventStatus.Seen));
      _databaseRepository.updateEventField(state.event.id, "Stato", EventStatus.Seen);
    }
  }

  void endEventAndNotify() {
    _databaseRepository.endEvent(state.event);
    emit(state.changeStatus(EventStatus.Ended));
    FirebaseMessagingService.sendNotifications(tokens: state.event.supervisor.tokens, title: "${_account.surname} ${_account.name} ha terminato il lavoro \"${state.event.title}\"");
  }

  void acceptEventAndNotify() {
    _databaseRepository.updateEventField(state.event.id, Constants.tabellaEventi_stato, EventStatus.Accepted);
    emit(state.changeStatus(EventStatus.Accepted));
    FirebaseMessagingService.sendNotifications(tokens: state.event.supervisor.tokens, title: "${_account.surname} ${_account.name} ha accettato il lavoro \"${state.event.title}\"");
  }

  void refuseEventAndNotify(String justification) {
    state.event.motivazione = justification;
    _databaseRepository.refuseEvent(state.event);
    emit(state.changeStatus(EventStatus.Refused));
    FirebaseMessagingService.sendNotifications(tokens: state.event.supervisor.tokens, title: "${_account.surname} ${_account.name} ha rifiutato il lavoro \"${state.event.title}\"");
  }

  void deleteEvent() {
    state.event.start.isBefore(DateTime.now())?
    _databaseRepository.deleteEventPast(state.event)
    :_databaseRepository.deleteEvent(state.event);
    PlatformUtils.backNavigator(context);
  }

  void modifyEvent() {
    //shh this is wrong, it breaks the mvvm
    PlatformUtils.backNavigator(context);
    PlatformUtils.navigator(context, Constants.createEventViewRoute, _event);
  }

}
