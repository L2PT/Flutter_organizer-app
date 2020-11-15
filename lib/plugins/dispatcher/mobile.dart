//custom import for mobile

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/mobile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'dart:io' show Platform;

abstract class PlatformUtils {
  PlatformUtils._();

  static const String platform = Constants.mobile;
  static dynamic myApp = MyApp();
  static const bool isMobile = true;
  static bool isIOS = Platform.isIOS;

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

  static Future<String> storageGetUrl(path) async {
    var a = await FirebaseStorage().ref().child(path).getDownloadURL();
    return a;
  }
  static Future<List<String>> storageGetFiles(path) async {
    return List<String>();//LONGTERMTODO maybe it will be implemented listAll is not available...
  }
  static void storagePutFile(path, PlatformFile file){
    FirebaseStorage().ref().child(path).putFile(new File(file.path));
  }
  static void storageDelFile(path){
    FirebaseStorage().ref().child(path).delete();
  }

  static dynamic download(url,filename) async {
    var localpath = await getExternalStorageDirectory();
    var res = FlutterDownloader.enqueue(
        url: url,
        savedDir: localpath.path,
        fileName: filename,
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: false, // click on notification to open downloaded file (for Android)
    );
    if(res == null) return false;
    return true;
  }
  static void initDownloader() => FlutterDownloader.initialize();

  static dynamic navigator(BuildContext context, route, [arg]) async {
    context.bloc<MobileBloc>().add(NavigateEvent(route, arg));
  }

  static void backNavigator(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else context.bloc<MobileBloc>().add(NavigateBackEvent());
  }

  static String getRoute(BuildContext context) =>
    context.bloc<MobileBloc>().state.route;
  

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

  static dynamic notifyInfoMessage(msg) {
    return Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

}
