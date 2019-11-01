//custom import for mobile

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:venturiautospurghi/mobile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';

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

  static const String platform = Constants.mobile;
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

  static dynamic fireDocuments(collection,{whereCondFirst,whereOp,whereCondSecond}) async {
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
    var a = await query.getDocuments();
    return a.documents;
  }

  static List<DocumentSnapshot> documents(querySnapshot) => querySnapshot.documents;

  static dynamic setDocument(collection, documentId, data) => fire.collection(collection).document(documentId).setData(data);

  static dynamic updateDocument(collection, documentId, data) =>
      fire.collection(collection).document(documentId).updateData(data);

  static dynamic fireDocument(collection, documentId) => fire.collection(collection).document(documentId);

  static dynamic extractFieldFromDocument(field, document){
    if(field != null){
      if(field == "id")
        return document.documentID;
      else
        return document.data[field];
    }
    else return document.data;
  }

  static dynamic navigator(context, content) async {
    return await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => content ));
  }

  static dynamic onErrorMessage(msg) {
    return Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static Event EventFromMap(id, color, json) => Event.fromMap(id, color, json);

  static Account AccountFromMap(id, json) => Account.fromMap(id, json);

}
