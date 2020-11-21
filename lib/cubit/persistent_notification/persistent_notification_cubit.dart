import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/plugins/firebase/firebase_messaging.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

part 'persistent_notification_state.dart';

class PersistentNotificationCubit extends Cubit<PersistentNotificationState> {
  final BuildContext context;
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  Timer safeChecker;

  PersistentNotificationCubit(this.context, CloudFirestoreService databaseRepository, Account account, List<Event> events) :
        assert(databaseRepository != null && account != null),
        _databaseRepository = databaseRepository, _account = account,
        super(PersistentNotificationState(events??[])) {
    _databaseRepository.subscribeEventsByOperatorWaiting(_account.id).listen((waitingEventsList) {
      safeChecker?.cancel();
      if(waitingEventsList.length == 0) context.bloc<MobileBloc>().add(RestoreEvent());
      emit(PersistentNotificationState(waitingEventsList));
    });
    safeChecker = new Timer(new Duration(seconds: 5), (){
      if(context.bloc<MobileBloc>().state is NotificationWaitingState && state.waitingEventsList.length == 0)
        context.bloc<MobileBloc>().add(RestoreEvent());
    });
  }

  void cardActionConfirm(Event event) {
    _databaseRepository.updateEventField(event.id, Constants.tabellaEventi_stato, Status.Accepted);
    FirebaseMessagingService.sendNotifications(tokens: event.supervisor.tokens, title: "${_account.surname} ${_account.name} ha accettato il lavoro \"${event.title}\"");
    context.bloc<MobileBloc>().add(RestoreEvent());
  }

  void cardActionRefuse(Event event, String justification) {
    event.motivazione = justification;
    _databaseRepository.refuseEvent(event);
    FirebaseMessagingService.sendNotifications(tokens: event.supervisor.tokens, title: "${_account.surname} ${_account.name} ha rifiutato il lavoro \"${event.title}\"");
    context.bloc<MobileBloc>().add(RestoreEvent());
  }

}
