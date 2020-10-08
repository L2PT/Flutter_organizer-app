import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:http/http.dart' as http;

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  CloudFirestoreService _databaseRepository;
  Account _account;
  BuildContext context;
  bool isInitialized = false;

  FirebaseMessagingService();

  void init(BuildContext context) async {
    this.context = context;
    this._account = context.bloc<AuthenticationBloc>().account;
    this._databaseRepository = context.repository<CloudFirestoreService>();
    isInitialized = true;
    if (Platform.isIOS) requestiOSPermission();
    //check if token is up to date
    String token = await _firebaseMessaging.getToken();
    if (token != _account.token) {
      _databaseRepository.updateAccountField(_account.id, "Token", token);
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
      Event event = await _updateEventAndSendFeedback(message, Status.Delivered);
      if(event != null) PlatformUtils.navigator(context, Constants.waitingNotificationRoute, [event]);
    }
  }

  Future<dynamic> onResumeHandler(Map<String, dynamic> message) async {
    if (Constants.debug) print('on resume: $message');
    _launchTheEvent(message);
  }

  Future<dynamic> onLaunchHandler(Map<String, dynamic> message) async {
    if (Constants.debug) print('on launch: $message');
    _launchTheEvent(message);
  }

  static Future<dynamic> onBackgroundMessageHandler(Map<String, dynamic> message) async {
    if (Constants.debug) print('on background message: $message');
    if (message.containsKey('data') && message['data']['id'] == null) {
      print("can't update to delivered sorry");
        // _updateEventAndSendFeedback(message, Status.Delivered);
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
    return message['notification']['body'] == null || message['notification']['body'] == "";
  }

  Future<Event> _updateEventAndSendFeedback(Map<String, dynamic> message, int newStatus) async {
      _databaseRepository.updateEventField(message['notification']['body'], "Stato", newStatus);
      Event event = await _databaseRepository.getEvent(message['notification']['body']);
      if(event != null) {
        Account supervisor = event.operator
          ..id = event.supervisor.id; //get here to prevent old token
        sendNotification(
            token: supervisor.token,
            title: "L'avviso è stato cosegnato a ${(event.operator as Account)
                .surname} ${(event.operator as Account).name}");
      }
      return event;
  }

  void _launchTheEvent(Map<String, dynamic> message) async {
    if (_isFeedbackNotification(message) && _account.supervisor) {
      PlatformUtils.navigator(context, Constants.waitingEventListRoute);
    } else if(!_isFeedbackNotification(message)){
      Event event = await _databaseRepository.getEvent(message['notification']['body']);
      if(event != null) PlatformUtils.navigator(context, Constants.waitingNotificationRoute, [event]);
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