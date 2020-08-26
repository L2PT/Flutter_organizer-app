@JS()
library jquery;
//custom import
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:venturiautospurghi/models/event.dart' as E;
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/web.dart';
import 'dart:async';
import 'package:universal_html/html.dart';
import 'package:universal_html/prefer_universal/html.dart';
import 'package:js_shims/js_shims.dart';

@JS()
external void storageOpenUrlJs(dynamic path);
external void storageGetUrlJs(dynamic path);
external void storagePutFileJs(dynamic path, dynamic file);
external void storageDelFileJs(dynamic path);

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
  static dynamic file(String path){
    String filename=path.substring(0,path.indexOf(":"));
    String dataurl=path.substring(path.indexOf(":")+1);
    var arr = dataurl.split(',');
    var bstr = base64.decode(arr[1]);
    int n = bstr.length;
    var u8arr = new Uint8List(n);

    for(var i=n; i<=0; i--){
      u8arr[i] = charCodeAt(bstr.toString(),i);
    }
    return new File([u8arr], filename);
  }

  static const dynamic Dir = null;

  static dynamic storageGetUrl(path){
    storageOpenUrlJs(path);
    return null;
  }
  static void storagePutFile(path, file){
    storagePutFileJs(path, file);
  }
  static void storageDelFile(path){
    storageDelFileJs(path);
  }

  static void download(url,filename) => null;
  static void initDownloader() => null;


  static Future<String> filePicker() async {
    final completer = new Completer<String>();
    final InputElement input = document.createElement('input');
    input..type = 'file';
    input.onChange.listen((e) async {
      final List<File> files = input.files;
      final reader = new FileReader();
      reader.readAsDataUrl(files[0]);
      reader.onError.listen((error) => completer.completeError(error));
      await reader.onLoad.first;
      completer.complete(files[0].name+":"+(reader.result as String));
    });
    input.click();
    String a = await completer.future;
    print(a);
    return a;
  }
  static Future<Map<String,String>> multiFilePicker() async {
    final completer = new Completer<List<String>>();
    final InputElement input = document.createElement('input');
    input
      ..type = 'file'
      ..multiple = true;
    input.onChange.listen((e) async {
      final List<File> files = input.files;
      Iterable<Future<String>> resultsFutures = files.map((file) {
        final reader = new FileReader();
        reader.readAsDataUrl(file);
        reader.onError.listen((error) => completer.completeError(error));
        return reader.onLoad.first.then((_) => reader.result as String);
      });
      final results = await Future.wait(resultsFutures);
      completer.complete(results);
    });
    input.click();
    var a = await completer.future;
    return Map.fromIterable(a, key: (s) => s.split("/").last, value: (s) => s);
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

  static dynamic notifyErrorMessage(msg) {
    showAlertJs(msg);
  }

  static E.Event EventFromMap(id, color, json) => E.Event.fromMap(id, color, json);

  static Account AccountFromMap(id, json) => Account.fromMapWeb(id, json);

}
