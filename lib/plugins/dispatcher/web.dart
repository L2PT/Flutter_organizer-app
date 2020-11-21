@JS()
library jquery;
//custom import
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:js_shims/js_shims.dart';
import 'package:venturiautospurghi/bloc/web_bloc/web_bloc.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

import '../../web.dart';


class PlatformUtils {
  PlatformUtils._();

//static void open(String url, {String name}) {
//    html.window.open(url, name);
//}

  static const String platform = Constants.web;
  static dynamic myApp = MyApp();
  static const bool isMobile = false;
  static const bool isIOS = false;

  static dynamic gestureDetector({dynamic child, Function onVerticalSwipe, dynamic swipeConfig}){
    throw 'Platform Not Supported';
  }
  static const dynamic simpleSwipeConfig = null;

  static const dynamic Dir = null;

  static dynamic storageGetUrl(path){
   storageOpenUrlJs(path);
    return null;
  }
  static Future<List<String>> storageGetFiles(path) async {
   var a = await promiseToFuture(storageGetFilesJs(path));
   return List<String>.from(a).map((file) => file.replaceAll(path, "")).toList();
  }
  static void storagePutFile(path, PlatformFile file){
   storagePutFileJs(path, new File(file.bytes, file.name));
  }
  static void storageDelFile(path){
   storageDelFileJs(path);
  }

  static bool download(url,filename) => false;
  static void initDownloader() => null;

  static dynamic navigator(BuildContext context, route, [arg]) async {
    context.bloc<WebBloc>().add(NavigateEvent(route, arg, context));
  }

  static void backNavigator(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else PlatformUtils.navigator(context, Constants.homeRoute);
  }

  static String getRoute(BuildContext context) =>
      context.bloc<WebBloc>().state.route;

  static dynamic notifyErrorMessage(msg) {
    showAlertJs(msg);
  }

  static dynamic notifyInfoMessage(msg) {
    showAlertJs(msg);
  }
}
