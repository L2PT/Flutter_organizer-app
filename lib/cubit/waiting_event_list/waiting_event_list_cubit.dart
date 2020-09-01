import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/bloc/web_bloc/web_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/firebase/firebase_messaging.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'waiting_event_list_state.dart';

class WaitingEventListCubit extends Cubit<WaitingEventListState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;

  WaitingEventListCubit( CloudFirestoreService databaseRepository, Account account) :
        assert(databaseRepository != null && account != null),
        _databaseRepository = databaseRepository, _account = account,
        super(LoadingEvents()) {
    databaseRepository.subscribeEventsByOperator(account.id).listen((waitingEventsList) {
      emit(ReadyEvents(waitingEventsList));
    });
    Future.delayed(
      Duration(seconds: 2), (){if(state is LoadingEvents) emit(ReadyEvents(List()));},
    );
  }

  void cardActionConfirm(Event event) {
    event.status = Status.Accepted;
    _databaseRepository.updateEventField(event.id, Constants.tabellaEventi_stato, Status.Accepted);
    FirebaseMessagingService.sendNotification(token:Account.fromMap("", event.supervisor).token, title: "${_account.surname} ${_account.name} ha accettato un lavoro");
  }

  void cardActionReject(Event event, ) {
    event.status = Status.Refused;
    _databaseRepository.updateEventField(event.id, Constants.tabellaEventi_stato, Status.Accepted);
    FirebaseMessagingService.sendNotification(token:Account.fromMap("", event.supervisor).token, title: "${_account.surname} ${_account.name}  ha rifiutato un lavoro");
  }

}
