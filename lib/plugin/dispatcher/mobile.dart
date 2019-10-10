//custom import for mobile
import 'dart:convert';

import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:venturiautospurghi/mobile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;


abstract class PlatformUtils {
  PlatformUtils._();

  //custom import for mobile
//  static void open(String url, {String name}) async {
//      if (await canLaunch(url)) {
//        await launch(url);
//      }else{
//        throw 'Could not launch $url';
//      }
//  }

  static void notify() async {
    String url = "https://fcm.googleapis.com/fcm/send";
    String json = "";
    Map<String,String> not = new Map<String,String>();
    json = "{\"to\":\"cergsGE37VU:APA91bHM1Ehi3GdHkM_L_McK1kM6rPpCUM-kE-AKPXuoHt48MBGrjEtzt3uBUW1MRX82U4IsJdPrRNSVGyab9qalL9Dqrz6IMeAZdgXeqOuqzHNQkz7l411iIWI-vD4EpzVLJas7fyWV\",";
    not['title'] = "It's time to work";
    not['body'] = "Hey, hai un nuovo lavoro.";
    json += "\"notification\":"+jsonEncode(not)+"}";
    var response = await http.post(url, body: json, headers: {"Authorization": "key=AIzaSyBF13XNJM1LDuRrLcWdQQxuEcZ5TakypEk","Content-Type": "application/json"},encoding: Encoding.getByName('utf-8'));
    print("response: "+jsonEncode(json));
    print("response: "+response.body);
  }

  static dynamic myApp = MyApp();

  static SimpleGestureDetector gestureDetector({dynamic child, Function onVerticalSwipe, SimpleSwipeConfig swipeConfig}){
    return SimpleGestureDetector(
      child: child,
      onVerticalSwipe: onVerticalSwipe,
      swipeConfig: swipeConfig,
    );
  }
  static const dynamic simpleSwipeConfig = SimpleSwipeConfig(
    verticalThreshold: 25.0,
    swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
  );
  static const dynamic Dir = SwipeDirection.up;
  static Firestore fire = new Firestore();

  static dynamic waitFireCollection(collection,{whereCondFirst,whereOp,whereCondSecond}) async {
    var query;
    if(whereOp!=null) {
      switch(whereOp){
        case "<" :{
          query = fire.collection(collection).where(whereCondFirst,isLessThan: whereCondSecond);
        }break;
        case "<=" :{
          query = fire.collection(collection).where(whereCondFirst,isLessThanOrEqualTo: whereCondSecond);
        }break;
        case "==" :{
          query = fire.collection(collection).where(whereCondFirst,isEqualTo: whereCondSecond);
        }break;
        case ">=" :{
          query = fire.collection(collection).where(whereCondFirst,isGreaterThanOrEqualTo: whereCondSecond);
        }break;
        case ">" :{
          query = fire.collection(collection).where(whereCondFirst,isGreaterThan: whereCondSecond);
        }break;
      }
    }else{
      query = fire.collection(collection);
    }
    return (await query.getDocuments()).documents;
  }

  static dynamic fireDocument(collection,document) => fire.collection(collection).document(document).get();

  static dynamic getFireDocumentField(document, field) => document.data[field];

}
