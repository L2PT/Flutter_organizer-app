//custom import for mobile

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/mobile.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'dart:io' show Platform;

import 'package:venturiautospurghi/utils/theme.dart';

abstract class PlatformUtils {
  PlatformUtils._();

  static const String platform = Constants.mobile;
  static dynamic myApp = MyApp();
  static const bool isMobile = true;
  static bool isIOS = Platform.isIOS;
  
  static dynamic download(url, filename) async {
    var localpath = await getExternalStorageDirectory();
    if (localpath != null) {
      return FlutterDownloader.enqueue(
        url: url,
        savedDir: localpath.path,
        fileName: filename,
        showNotification: true,
        // show download progress in status bar (for Android)
        openFileFromNotification: false, // click on notification to open downloaded file (for Android)
      ) != null;
    }
  }
  
  static void initDownloader() => FlutterDownloader.initialize();

  static dynamic navigator(BuildContext context, route, [arg]) async {
    context.read<MobileBloc>().add(NavigateEvent(route, arg));
  }

  static Future<bool> backNavigator(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else context.read<MobileBloc>().add(NavigateBackEvent());
    return Future<bool>(()=>false);
  }

  static String getRoute(BuildContext context) =>
    context.read<MobileBloc>().state.route;
  

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
        backgroundColor: black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  static dynamic eventButtonsVisible(BuildContext context, event, account){
    return event.isSeen() && context.read<MobileBloc>().savedState.route != Constants.waitingEventListRoute && event._operator.id == account.id;
  }

}
