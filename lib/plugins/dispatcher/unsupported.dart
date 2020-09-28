import 'package:flutter/src/widgets/framework.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

abstract class PlatformUtils {
  PlatformUtils._();

/* Example
  static void open(String url, {String name}) {
    throw 'Platform Not Supported';
  }
*/

  static const String platform = null;
  static const dynamic myApp = null;

  static dynamic gestureDetector(
      {dynamic child, Function onVerticalSwipe, dynamic swipeConfig}) {
    throw 'Platform Not Supported';
  }

  static const dynamic simpleSwipeConfig = null;
  static dynamic file(path) => null;

  static const dynamic Dir = null;
  static dynamic storageGetUrl(path) => null;
  static Future<List<String>> storageGetFiles(path) => null;
  static void storagePutFile(path, file) => null;
  static void storageDelFile(path) => null;
  static dynamic download(url,filename) => null;
  static void initDownloader() => null;

  static Future<Map<String,String>> filePicker() => null;
  static Future<Map<String,String>> multiFilePicker() => null;

  static dynamic navigator(context, route, [arg]) => null;
  static void backNavigator(BuildContext context) => null;
  static String getRoute( context) => Constants.homeRoute;

  static dynamic notifyErrorMessage(msg) => null;

  static dynamic notifyInfoMessage(message) => null;

}