import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/bloc/web_bloc/web_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'waiting_event_list_state.dart';

class WaitingEventListCubit extends Cubit<WaitingEventListState> {

  WaitingEventListCubit( CloudFirestoreService databaseRepository, Account account) :
        assert(databaseRepository != null && account != null),
        super(LoadingEvents()) {
    databaseRepository.subscribeEventsByOperator(account.id).listen((waitingEventsList) {
      emit(ReadyEvents(waitingEventsList));
    });
    Future.delayed(
      Duration(seconds: 2), (){if(state is LoadingEvents) emit(ReadyEvents(List()));},
    );
  }

}
