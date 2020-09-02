import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';

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
  static dynamic storageGetFiles(path) => null;
  static void storagePutFile(path, file) => null;
  static void storageDelFile(path) => null;
  static dynamic download(url,filename) => null;
  static void initDownloader() => null;

  static Future<String> filePicker() => null;
  static Future<Map<String,String>> multiFilePicker() => null;

  static dynamic navigator(context, route, [arg]) => null;

  static dynamic notifyErrorMessage(msg) => null;
  static dynamic notifyInfoMessage(message) => null;

  static Event EventFromMap(id, color, json) => null;

  static Account AccountFromMap(id, json) => null;

}