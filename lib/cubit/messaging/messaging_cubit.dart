import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_messaging_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';

part 'messaging_state.dart';

class MessagingCubit extends Cubit<MessagingState> {
  final CloudFirestoreService _databaseRepository;
  final FirebaseMessagingService _messagingRepository;
  final Account _account;

  MessagingCubit(this._databaseRepository, this._messagingRepository, this._account)
      : super(MessagingState()) {

    updateAccountTokens();
    _messagingRepository.init(onMessageHandler, onResumeHandler, onBackgroundMessageHandler);
  }
  
  void updateAccountTokens() async {
    String? token = await FirebaseMessagingService.getToken();
    if(token != null) {
      if (!_account.tokens.contains(token)) {
        _account.tokens.add(token);
        _databaseRepository.updateAccountField(_account.id, "Tokens", _account.tokens);
        if (Constants.debug) print("New token: " + token);
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
    emit(state.assign());
  }

  void onMessageHandler(RemoteMessage message) async {
    if (Constants.debug) print('on message: $message');
    if (_isFeedbackNotification(message)) {// TODO add a check for null title after debug session
      PlatformUtils.notifyInfoMessage(message.notification?.title??"");
    } else {
      _updateEventAndSendFeedback(message, EventStatus.Delivered);
    }
  }

  void onResumeHandler(RemoteMessage message) async {
    if (Constants.debug) print('on resume: $message');
    _launchTheEvent(message);
  }

  void onBackgroundMessageHandler(RemoteMessage message) async {
    if (Constants.debug) print('on background message: $message');
    if (_isFeedbackNotification(message)) {
      _updateEventAndSendFeedback(message, EventStatus.Delivered);
    }
  }
  
  bool _isFeedbackNotification(RemoteMessage message) {
    return string.isNullOrEmpty(message.data['id']);
  }

  Future<Event?> _updateEventAndSendFeedback(RemoteMessage message, int updatedStatus) async {
    Event? event = await _databaseRepository.getEvent(message.data['id']);
    if(event != null && (updatedStatus == EventStatus.Delivered && event.isNew())) {
      Account supervisor = await _databaseRepository.getAccount(event.supervisor!.email);
      _databaseRepository.updateEventField(message.data['id'], Constants.tabellaEventi_stato, updatedStatus);
      FirebaseMessagingService.sendNotifications(
          tokens: supervisor.tokens,
          title: "L'avviso è stato cosegnato a ${event.operator?.surname} ${event.operator?.name}");
    }
    return event;
  }

  void _launchTheEvent(RemoteMessage message) async { // TODO ask for the behaviour
    if (_isFeedbackNotification(message) && !_account.supervisor) {
      emit(state.assign());
    } else if(!_isFeedbackNotification(message)){
      Event? event = await _updateEventAndSendFeedback(message, EventStatus.Delivered);
      if(event != null){
        emit(state.assign(event: event));
      }
    }
  }
  
}