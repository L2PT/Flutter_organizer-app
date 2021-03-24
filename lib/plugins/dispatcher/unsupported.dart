import 'package:file_picker/file_picker.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

abstract class PlatformUtils {

  PlatformUtils._();

/* Example
  static void open(String url, {String name}) {
    throw 'Platform Not Supported';
  }
*/

  static const String platform = "";
  static const dynamic myApp = null;
  static const bool isMobile = true;
  static const bool isIOS = true;

  static dynamic download(url,filename) => null;
  static void initDownloader() => null;
  static dynamic file(path) => null;

  static dynamic navigator(context, route, [arg]) => null;
  static Future<bool> backNavigator(BuildContext context) => Future<bool>(()=>false);
  static String getRoute( context) => Constants.homeRoute;

  static dynamic notifyErrorMessage(msg) => null;

  static dynamic notifyInfoMessage(message) => null;

  static dynamic eventButtonsVisible(BuildContext context, event, account) => null;
}