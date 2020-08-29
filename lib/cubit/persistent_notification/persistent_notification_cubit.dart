import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';

part 'persistent_notification_state.dart';

class PersistentNotificationCubit extends Cubit<PersistentNotificationState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;

  PersistentNotificationCubit( CloudFirestoreService databaseRepository, Account account) :
        assert(databaseRepository != null && account != null),
        _databaseRepository = databaseRepository, _account = account,
        super(PersistentNotificationState(List())) {
    _databaseRepository.subscribeEventsByOperatorWaiting(_account.id).listen((waitingEventsList) {
      emit(PersistentNotificationState(waitingEventsList));
    });
  }

  //TODO can i remove the variables?
}
