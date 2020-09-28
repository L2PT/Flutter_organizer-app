import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/plugins/firebase/firebase_messaging.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

part 'persistent_notification_state.dart';

class PersistentNotificationCubit extends Cubit<PersistentNotificationState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;

  PersistentNotificationCubit( CloudFirestoreService databaseRepository, Account account, List<Event> events) :
        assert(databaseRepository != null && account != null),
        _databaseRepository = databaseRepository, _account = account,
        super(PersistentNotificationState(events)) {
    _databaseRepository.subscribeEventsByOperatorWaiting(_account.id).listen((waitingEventsList) {
      emit(PersistentNotificationState(waitingEventsList));
    });
  }

  void cardActionConfirm(Event event) {
    _databaseRepository.updateEventField(event.id, Constants.tabellaEventi_stato, Status.Accepted);
    FirebaseMessagingService.sendNotification(token: event.supervisor.token, title: "${_account.surname} ${_account.name} ha accettato un lavoro");
    //TODO AGGIUGERE LA NAVIGAZIONE ALLA HOME
  }

  void cardActionReject(Event event) {
      _databaseRepository.updateEventField(event.id, Constants.tabellaEventi_stato, Status.Refused);
      FirebaseMessagingService.sendNotification(token: event.supervisor.token, title: "${_account.surname} ${_account.name}  ha rifiutato un lavoro");
    //TODO AGGIUGERE LA NAVIGAZIONE ALLA HOME
  }

}
