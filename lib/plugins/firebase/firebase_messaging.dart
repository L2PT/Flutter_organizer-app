import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:http/http.dart' as http;

class FirebaseMessagingService {
  final CloudFirestoreService _databaseRepository;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Account account;
  BuildContext context;

  FirebaseMessagingService(this._databaseRepository);

  void init(Account account, BuildContext context) async {
    this.account = account;
    this.context = context;
    if (Platform.isIOS) requestiOSPermission();
    //check if token is up to date
    String token = await _firebaseMessaging.getToken();
    if (token != account.token) {
      _databaseRepository.updateAccountField(account.id, "Token", token);
      if (Constants.debug) print("New token: " + token);
    }

    _firebaseMessaging.configure(
      onMessage: onMessageHandler,
      onResume: onResumeHandler,
      onLaunch: onLaunchHandler,
      onBackgroundMessage: onBackgroundMessageHandler,
    );

  }

  Future<dynamic> onMessageHandler(Map<String, dynamic> message) async {
    if (Constants.debug) print('on message: $message');
    if (_isFeedbackNotification(message)) {
      PlatformUtils.notifyInfoMessage(message["notification"]["title"]);
    } else {
      _updateEventAndSendFeedback(message, Status.Delivered);
    }
  }

  Future<dynamic> onResumeHandler(Map<String, dynamic> message) async {
    if (Constants.debug) print('on resume: $message');
    _openTheEvent(message);
  }

  Future<dynamic> onLaunchHandler(Map<String, dynamic> message) async {
    if (Constants.debug) print('on launch: $message');
    _openTheEvent(message);
  }

  static Future<dynamic> onBackgroundMessageHandler(Map<String, dynamic> message) async {
    if (Constants.debug) print('on background message: $message');
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      if(message['data']['id'].isNullOrEmpty()){
        CloudFirestoreService databaseRepository = await CloudFirestoreService.create();
        databaseRepository.updateEventField(message['data']['id'], "Stato", Status.Delivered);
        Event event = await databaseRepository.getEvent(message['data']['id']);
        Account supervisor = event.operator
          ..id = event.supervisor.id; //get here to prevent old token
        sendNotification(
            token: supervisor.token,
            title: "L'avviso è stato cosegnato a ${(event.operator as Account)
                .surname} ${(event.operator as Account).name}");
      }
    }
  }

  void requestiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((
        IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  bool _isFeedbackNotification(Map<String, dynamic> message) {
    return message['data']['id'].isNullOrEmpty();
  }

  Future<Event> _updateEventAndSendFeedback(Map<String, dynamic> message,
      int newStatus) async {
    _databaseRepository.updateEventField(message['data']['id'], "Stato", newStatus);
    Event event = await _databaseRepository.getEvent(message['data']['id']);
    Account supervisor = event.operator
      ..id = event.supervisor.id; //get here to prevent old token
    sendNotification(
        token: supervisor.token,
        title: "L'avviso è stato cosegnato a ${(event.operator as Account)
            .surname} ${(event.operator as Account).name}");
    return event;
  }

  //TODO to test the expected behaviour is the app opens in notification status and automatically to the event
  void _openTheEvent(Map<String, dynamic> message) async {
    if (_isFeedbackNotification(message) && account.supervisor) {
      context.bloc<MobileBloc>().add(
          NavigateEvent(Constants.waitingEventListRoute, null));
    } else {
      Event event = await _databaseRepository.getEvent(message['data']['id']);
      PlatformUtils.navigator(context, event);
    }
  }

  static void sendNotification({token = "",
    title = "Nuovo incarico assegnato",
    description = "Clicca la notifica per vedere i dettagli",
    eventId = ""}) async {
    String url = "https://fcm.googleapis.com/fcm/send";
    String json = "";
    Map<String, String> notification = new Map<String, String>();
    Map<String, String> data = new Map<String, String>();
    json = "{\"to\":\"$token\",";
    notification['title'] = title;
    notification['body'] = description;
    notification['click_action'] = "FLUTTER_NOTIFICATION_CLICK";
    data['id'] = eventId;
    json += "\"notification\":" + jsonEncode(notification) + ", \"data\":" +
        jsonEncode(data) + "}";
    var response = await http.post(
        url,
        body: json,
        headers: {
          "Authorization": "key=AIzaSyBF13XNJM1LDuRrLcWdQQxuEcZ5TakypEk",
          "Content-Type": "application/json"
        },
        encoding: Encoding.getByName('utf-8'));
    print("response: " + jsonEncode(json));
    print("response: " + response.body);
  }


}