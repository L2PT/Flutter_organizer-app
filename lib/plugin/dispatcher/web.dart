//custom import
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/web.dart';


class PlatformUtils {
  PlatformUtils._();

//static void open(String url, {String name}) {
//    html.window.open(url, name);
//}

  static dynamic myApp = MyApp();

  static dynamic gestureDetector({dynamic child, Function onVerticalSwipe, dynamic swipeConfig}){
    throw 'Platform Not Supported';
  }
  static const dynamic simpleSwipeConfig = null;
  static const dynamic Dir = null;
  static dynamic fire = firestore();

  static dynamic waitFireCollection(collection,{whereCondFirst,whereOp,whereCondSecond}) async {
    var query;
    if(whereOp!=null) {
      query = fire.collection(collection).where(whereCondFirst,whereOp,whereCondSecond);
    }else{
      query = fire.collection(collection);
    }
    var a = await query.get();
    return a.docs;
  }

  static dynamic setDocument(collection, documentId, data) => fire.collection(collection).doc(documentId).set(data);

  static dynamic fireDocument(collection,documentId) => fire.collection(collection).doc(documentId);

  static dynamic extractFieldFromDocument(field, document){
    if(field != null){
      if(field == "id")
        return document.id;
      else
        return document.get(field);
    }
    else return document.data();
  }

  static dynamic navigator(context, content) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(contentPadding: EdgeInsets.all(0),content:Container(height:600, width:400, child: content),
        );
      },
    );
  }

  static Event EventFromMap(id, color, json) => Event.fromMapWeb(id, color, json);

}
