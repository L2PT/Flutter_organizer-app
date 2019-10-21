
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_auth/fb_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/view/details_event_view.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;

FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void firebaseCloudMessaging_Listeners(AuthUser user, BuildContext context){
  if (Platform.isIOS) iOS_Permission();

  _firebaseMessaging.getToken().then((token) async {
    QuerySnapshot documents = (await Firestore.instance.collection(global.Constants.tabellaUtenti).getDocuments());
    var e = user.email;
    for (DocumentSnapshot document in documents.documents) {
      if(document != null && document.data['Email'] == e) {
        if(document.data['Token'] != token){
          Firestore.instance.collection(global.Constants.tabellaUtenti).document(document.documentID).updateData(<String,dynamic>{"Token":token});
        }
        break;
      }
    }
    print("token: "+token);
  });

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
      //TODO notifica persistente
    },
    onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      //TODO quando salvo l'evento
      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new DetailsEvent(Event.empty(),false)));
    },
    onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      //TODO quando salvo l'evento
      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new DetailsEvent(Event.empty(),false)));
    },
  );
}

void iOS_Permission() {
  _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true)
  );
  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings)
  {
    print("Settings registered: $settings");
  });
}