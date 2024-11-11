import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:venturiautospurghi/utils/global_constants.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging;
  bool enabled = false;
  
  FirebaseMessagingService([FirebaseMessaging? firebaseMessaging])
      : _firebaseMessaging = firebaseMessaging ??  FirebaseMessaging.instance;
  
  static Future<FirebaseMessagingService> create() async {
    FirebaseMessagingService instance = FirebaseMessagingService();

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    return instance;
  }
  void init(handlerOnMessage, handlerOnMessageOpenedApp, handlerOnBackgroundMessage) async {
    bool enabled = await requestPermission();
    
    // set handlers
    if (enabled) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null)
          handlerOnMessage?.call(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.notification != null)
          handlerOnMessageOpenedApp?.call(message);
      });
      
      // https://firebase.flutter.dev/docs/messaging/usage/#background-messages
      FirebaseMessaging.onBackgroundMessage(handlerOnBackgroundMessage);

      _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          RemoteNotification? notification = message.notification;
          AndroidNotification? android = message.notification?.android;

          if (notification != null && android != null)
            handlerOnMessage?.call(message);
        }
      });
    }
  }  
  
  Future<bool> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  static Future<String?> getToken()=> FirebaseMessaging.instance.getToken();

  static void sendNotifications({
      tokens = const [],
      title = "Nuovo incarico assegnato",
      description = "Clicca la notifica per vedere i dettagli",
      style = Constants.notificationInfoTheme,
      type = Constants.eventNotification,
      eventId = ""}
      ) async {
    Uri url =  Uri.parse("https://fcm.googleapis.com/fcm/send");
    tokens.forEach((token) async {
      Map<String, String> notification = new Map<String, String>();
      Map<String, String> data = new Map<String, String>();
      notification['title'] = title;
      notification['body'] = description;
      notification['sound'] = "default";
      data['id'] = eventId;
      data['style'] = style;
      data['type'] = type;
      data['click_action'] = "FLUTTER_NOTIFICATION_CLICK";


      String json = "{\"to\":\"$token\", \"notification\":" + jsonEncode(notification) + ", \"data\":" + jsonEncode(data) + "}";
      var response = await http.post(
          url,
          body: json,
          headers: {
            "Authorization": "key=${Constants.googleMessagingApiKey}",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          encoding: Encoding.getByName('utf-8'));
      if(Constants.debug) print("response: " + jsonEncode(json));
      if(Constants.debug) print("response: " + response.body);
    });
  }

}