@JS()
library jquery;
//custom import
import 'dart:async';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:js/js.dart';
import 'package:venturiautospurghi/bloc/web_bloc/web_bloc.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

import '../../web.dart';


class PlatformUtils {
  PlatformUtils._();

  static const String platform = Constants.web;
  static dynamic myApp = MyApp();
  static const bool isMobile = false;
  static const bool isIOS = false;
  
  static dynamic download(url,filename) => false;
  static void initDownloader() => null;

  static dynamic navigator(BuildContext context, route, [arg]) async {
    context.read<WebBloc>().add(NavigateEvent(route, arg, context));
  }

  static Future<bool> backNavigator(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else PlatformUtils.navigator(context, Constants.homeRoute);
    return Future<bool>(()=>false);
  }

  static String getRoute(BuildContext context) =>
      context.read<WebBloc>().state.route;

  static dynamic notifyErrorMessage(msg) {
    showAlertJs(msg);
  }

  static dynamic notifyInfoMessage(msg) {
    showAlertJs(msg);
  }

  static dynamic eventButtonsVisible(BuildContext context, event, account){
    return false;
  }
}
