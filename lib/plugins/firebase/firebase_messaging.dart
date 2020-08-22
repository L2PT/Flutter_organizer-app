import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/theme.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void firebaseCloudMessaging_Listeners(String email, BuildContext context) {
  if (Platform.isIOS) iOS_Permission();
  //check if token is up to date
  _firebaseMessaging.getToken().then((token) async {
//    QuerySnapshot documents = (await Firestore.instance.collection(global.Constants.tabellaUtenti).getDocuments());
//    for (DocumentSnapshot document in documents.documents) {
//      if (document != null && document.data['Email'] == email) {
//        if (document.data['Token'] != token) {
//          Firestore.instance
//              .collection(global.Constants.tabellaUtenti)
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
            token: Account.fromMap(event.idSupervisor, event.supervisor).token,
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
            token: Account.fromMap(event.idSupervisor, event.supervisor).token,
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
            token: Account.fromMap(event.idSupervisor, event.supervisor).token,
            title: "L'avviso è stato cosegnato a " + operator.surname + " " + operator.name);
        Utils.NavigateTo(context, global.Constants.waitingEventListRoute, event);
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
