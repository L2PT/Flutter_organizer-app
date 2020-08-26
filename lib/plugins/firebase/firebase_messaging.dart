import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:http/http.dart' as http;

class FirebaseMessagingService {

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void firebaseCloudMessaging_Listeners(String email, BuildContext context) {
    if (Platform.isIOS) iOS_Permission();
    //check if token is up to date
    _firebaseMessaging.getToken().then((token) async {
//    QuerySnapshot documents = (await Firestore.instance.collection(Constants.tabellaUtenti).getDocuments());
//    for (DocumentSnapshot document in documents.documents) {
//      if (document != null && document.data['Email'] == email) {
//        if (document.data['Token'] != token) {
//          Firestore.instance
//              .collection(Constants.tabellaUtenti)
//              .document(document.documentID)
//              .updateData(<String, dynamic>{"Token": token});
//        }
//        break;
//      }
//    }
      print("token: " + token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message: $message');
        if (!message['data']['id'].isNullOrEmpty()) {
          Event event = await EventsRepository().getEvent(message['data']['id']);
          EventsRepository().updateEvent(event, "Stato", Status.Delivered);
          Account operator = Account.fromMap(event.idOperator, event.operator);
          Utils.notify(
              token: Account
                  .fromMap(event.idSupervisor, event.supervisor)
                  .token,
              title: "L'avviso è stato cosegnato a " + operator.surname + " " + operator.name);
        } else {
          Fluttertoast.showToast(
              msg: message["notification"]["title"],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: black,
              textColor: white,
              fontSize: 16.0);
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume: $message');
        if (!message['data']['id'].isNullOrEmpty()) {
          Event event = await EventsRepository().getEvent(message['data']['id']);
          EventsRepository().updateEvent(event, "Stato", Status.Delivered);
          Account operator = Account.fromMap(event.idOperator, event.operator);
          Utils.notify(
              token: Account
                  .fromMap(event.idSupervisor, event.supervisor)
                  .token,
              title: "L'avviso è stato cosegnato a " + operator.surname + " " + operator.name);
          Utils.PushViewDetailsEvent(context, event);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch: $message');
        if (!message['data']['id'].isNullOrEmpty()) {
          Event event = await EventsRepository().getEvent(message['data']['id']);
          EventsRepository().updateEvent(event, "Stato", Status.Delivered);
          Account operator = Account.fromMap(event.idOperator, event.operator);
          Utils.notify(
              token: Account
                  .fromMap(event.idSupervisor, event.supervisor)
                  .token,
              title: "L'avviso è stato cosegnato a " + operator.surname + " " + operator.name);
          Utils.NavigateTo(context, Constants.waitingEventListRoute, event);
        }
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  static void sendNotification(
      {token = "eGIwmXLpg_c:APA91bGkJI5Nargw6jjiuO9XHxJYcJRL1qfg0CjmnblAsZQ8k-kPQXCCkalundHtsdS21_clryRplzXaSgCj6PM1geEmXttijdSCWQuMQWUHpjPZ9nJOaNFqC6Yq6Oa5WixzyObXr8gt",
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
    json += "\"notification\":" + jsonEncode(notification) + ", \"data\":" + jsonEncode(data) + "}";
    var response = await http.post(
        url,
        body: json,
        headers: {"Authorization": "key=AIzaSyBF13XNJM1LDuRrLcWdQQxuEcZ5TakypEk",
          "Content-Type": "application/json"},
        encoding: Encoding.getByName('utf-8'));
    print("response: " + jsonEncode(json));
    print("response: " + response.body);
  }

}