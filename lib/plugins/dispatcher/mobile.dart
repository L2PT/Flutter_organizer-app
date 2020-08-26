//custom import for mobile

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:venturiautospurghi/mobile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';

abstract class PlatformUtils {
  PlatformUtils._();

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
  static dynamic file(path) => File(path);

  static const dynamic Dir = SwipeDirection.up;

  static Future<String> storageGetUrl(path) async {
    var a = await FirebaseStorage().ref().child(path).getDownloadURL();
    return a;
  }
  static Future<List<String>> storageGetFiles(path) async {
    return List<String>();//LONGTERMTODO maybe it will be implemented listAll is not available...
  }
  static void storagePutFile(path, file){
    FirebaseStorage().ref().child(path).putFile(file);
  }
  static void storageDelFile(path){
    FirebaseStorage().ref().child(path).delete();
  }

  static dynamic download(url,filename) async {
    var localpath = await getExternalStorageDirectory();
    FlutterDownloader.enqueue(
        url: url,
        savedDir: localpath.path,
        fileName: filename,
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: false, // click on notification to open downloaded file (for Android)
    );
  }
  static void initDownloader() => FlutterDownloader.initialize();

  static Future<String> filePicker() async {
    var a = await FilePicker.getFilePath();
    return a;
  }
  static Future<Map<String,String>> multiFilePicker() async {
    var a = await FilePicker.getMultiFilePath();
    return a;
  }

  static dynamic navigator(context, content) async {
    return await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => content ));
  }

  static dynamic notifyErrorMessage(msg) {
    return Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static Event EventFromMap(id, color, json) => Event.fromMap(id, color, json);

  static Account AccountFromMap(id, json) => Account.fromMap(id, json);

}
