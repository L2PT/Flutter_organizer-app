import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_messaging_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

part 'messaging_state.dart';

class MessagingCubit extends Cubit<MessagingState> {
  final CloudFirestoreService _databaseRepository;
  final FirebaseMessagingService _messagingRepository;
  final Account _account;

  MessagingCubit(this._databaseRepository, this._messagingRepository, this._account)
      : super(MessagingState()) {

    if(PlatformUtils.isMobile) {
      _messagingRepository.init(onMessageHandler, onResumeHandler, onBackgroundMessageHandler);
      updateAccountTokens();
    }
  }
  
  void updateAccountTokens([String? currentToken]) async {
    String? token = currentToken ?? await FirebaseMessagingService.getToken();
    if(token != null) {
      //TODO cambiare struttura db per i token for web reliability (è possibile/necessario avere più sessioni web collegate)
      if (!_account.tokens.contains(token)) {
        _account.tokens.add(token);
        _databaseRepository.updateAccountField(_account.id, "Tokens", _account.tokens);
        if (Constants.debug) print("New token added: " + token);
      }
    }
  }
  
  void removeAccountToken() async {
    String? token = await FirebaseMessagingService.getToken();
    if(token != null) {
      if (_account.tokens.contains(token)) {
        _account.tokens.remove(token);
        _databaseRepository.updateAccountField(_account.id, "Tokens", _account.tokens);
      }
    }
    emit(state.signOut());
  }

  void onMessageHandler(RemoteMessage message) async {
    if (Constants.debug) print('on message: $message');
    if (_isFeedbackNotification(message)) {
      PlatformUtils.notifyInfoMessage(message.notification?.title??"");
    } else {
      _updateEventAndSendFeedback(message, EventStatus.Delivered);
    }
  }

  void onResumeHandler(RemoteMessage message) async {
    if (Constants.debug) print('on resume: $message');
    _launchTheEvent(message);
  }

  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    if (Constants.debug) print('on background message: $message');
    if (_isFeedbackNotification(message)) {
      CloudFirestoreService.backgroundUpdateEventAsDelivered(message.data['id']);
    }
  }
  
  static bool _isFeedbackNotification(RemoteMessage message) {
    return message.data['type'] == Constants.feedNotification;
  }

  Future<Event?> _updateEventAndSendFeedback(RemoteMessage message, int updatedStatus) async {
    Event? event = await _databaseRepository.getEvent(message.data['id']);
    if(event != null && (updatedStatus == EventStatus.Delivered && event.isNew())) {
      _databaseRepository.updateEventField(message.data['id'], Constants.tabellaEventi_stato, updatedStatus);
      // The requirements changed...
      // Account supervisor = await _databaseRepository.getAccount(event.supervisor.email);
      // FirebaseMessagingService.sendNotifications(
      //     tokens: supervisor.tokens,
      //     priority: Constants.notificationInfoTheme,
      //     title: "L'avviso è stato cosegnato a ${event.operator?.surname} ${event.operator?.name}",
      //     eventId: state.event.id
      // );
    }
    return event;
  }

  void launchTheEvent(String id) async {
    Event? event = await _databaseRepository.getEvent(id);
    if(event != null) {
      emit(state.assign(event: event));
    }
  }

  void _launchTheEvent(RemoteMessage message) async {
    if (!_isFeedbackNotification(message)){
      Event? event = await _updateEventAndSendFeedback(message, EventStatus.Delivered);
      if(event != null){
        emit(state.assign(event: event));
      }
    }
  }
  
}