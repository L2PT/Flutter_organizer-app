//custom import
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/web.dart';
import 'dart:async';
import 'dart:html';


class PlatformUtils {
  PlatformUtils._();

//static void open(String url, {String name}) {
//    html.window.open(url, name);
//}

  static const String platform = Constants.web;
  static dynamic myApp = MyApp();

  static dynamic gestureDetector({dynamic child, Function onVerticalSwipe, dynamic swipeConfig}){
    throw 'Platform Not Supported';
  }
  static const dynamic simpleSwipeConfig = null;
  static dynamic file(path) => null;

  static const dynamic Dir = null;
  static dynamic fire = fb.firestore();

  static dynamic storage = fb.storage();

  static dynamic download(url,filename){window.open(url, 'tab');}
  static void initDownloader() => null;


  static Future<String> filePicker() {
//    final completer = new Completer<String>();
//    final InputElement input = document.createElement('input');
//    input..type = 'file';
//    input.onChange.listen((e) async {
//      final List<File> files = input.files;
//      final reader = new FileReader();
//      reader.readAsDataUrl(files[0]);
//      reader.onError.listen((error) => completer.completeError(error));
//      await reader.onLoad.first;
//      completer.complete(reader.result as String);
//    });
//    input.click();
//    return completer.future;
  }

  static Future<Map<String,String>> multiFilePicker() {
//    final completer = new Completer<List<String>>();
//    final InputElement input = document.createElement('input');
//    input
//      ..type = 'file'
//      ..multiple = true;
//    input.onChange.listen((e) async {
//      final List<File> files = input.files;
//      Iterable<Future<String>> resultsFutures = files.map((file) {
//        final reader = new FileReader();
//        reader.readAsDataUrl(file);
//        reader.onError.listen((error) => completer.completeError(error));
//        return reader.onLoad.first.then((_) => reader.result as String);
//      });
//      final results = await Future.wait(resultsFutures);
//      completer.complete(results);
//    });
//    input.click();
//    return completer.future;
  }

  static dynamic fireDocuments(collection,{whereCondFirst,whereOp,whereCondSecond}) async {
    var query;
    if(whereOp!=null) {
      query = fire.collection(collection).where(whereCondFirst,whereOp,whereCondSecond);
    }else{
      query = fire.collection(collection);
    }
    var a = await query.get();
    return a.docs;
  }

  static List documents(querySnapshot) => querySnapshot.docs;

  static dynamic setDocument(collection, documentId, data) => fire.collection(collection).doc(documentId).set(data);

  static dynamic updateDocument(collection, documentId, data) => fire.collection(collection).doc(documentId).update( data: data);

  static dynamic fireDocument(collection,documentId) => fire.collection(collection).doc(documentId);

  static dynamic customCollectionGroup(categories){
    return fb.firestore().collectionGroup(Constants.subtabellaStorico).onSnapshot.map((snapshot) {
      return documents(snapshot).map((doc) {
        String cat = extractFieldFromDocument("Categoria", doc);
        return Event.fromMap(extractFieldFromDocument("id", doc), categories!=null?
        categories[cat] != null
            ? categories[cat]
            : categories['default']:Constants.fallbackHexColor, extractFieldFromDocument(null, doc));})
          .toList();
    });
  }

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
        return AlertDialog(contentPadding: EdgeInsets.all(0),content:Container(height:650, width:400, child: content),
        );
      },
    );
  }

  static dynamic onErrorMessage(msg) {
    showAlert(msg);
  }

  static Event EventFromMap(id, color, json) => Event.fromMapWeb(id, color, json);

  static Account AccountFromMap(id, json) => Account.fromMapWeb(id, json);

}
