library App.utils;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:http/http.dart' as http;
import 'package:venturiautospurghi/view/details_event_view.dart';
import 'package:venturiautospurghi/view/form_event_creator_view.dart';

class Utils {
  static Future<Map<String,dynamic>> getCategories() async {
    Map <String,dynamic> categories;
    var doc = await PlatformUtils.fire.collection("Costanti").document("Categorie").get();
    if (doc.exists) {
      categories = doc.data;
      categories['default'] = global.Constants.fallbackHexColor;
    } else {
      print("No categories!");
    }
    return categories;
  }

  static Future<Color> getColor(arg) async {
    Map <String,dynamic> categories;
    var doc = await PlatformUtils.fire.collection("Costanti").document("Categorie").get();
    if (doc.exists) {
      categories = doc.data;
      categories['default'] = global.Constants.fallbackHexColor;
    } else {
      print("No categories!");
    }
    return HexColor((arg != null && categories[arg] != null)
        ? categories[arg]
        : categories['default']);
  }

  static String formatDateString(DateTime date, String format) {
    int year = date.year, month = 1, day = 1;
    if(format == "month" || format == "day") month = date.month;
    if(format == "day") day = date.day;

    return year.toString() + '-' + ((month/10<1)?"0"+month.toString():month.toString()) + '-' + ((day/10<1)?"0"+day.toString():day.toString());
  }
  static DateTime formatDate(DateTime date, String format) {
    return DateTime.parse(formatDateString(date, format));
  }
  static bool isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  static void notify() async {
    String url = "https://fcm.googleapis.com/fcm/send";
    String json = "";
    Map<String,String> not = new Map<String,String>();
    json = "{\"to\":\"ck8kAtvOi9Y:APA91bFhG2-GpsSLu1I0JGAAH4yx1-IPocnqCWpOAlyCcHzZsr9GYpEub1SMvLbiwqecGzPus1EUtEZXgCQZurZQAM0GXerI-hrvgMx5FXN8ttNkZCRz34-CrlACXZEysqpsakMRquIu:APA91bFhG2\",";
    not['title'] = "It's time to work";
    not['body'] = "Hey, hai un nuovo lavoro.";
    json += "\"notification\":"+jsonEncode(not)+"}";
    var response = await http.post(url, body: json, headers: {"Authorization": "key=AIzaSyBF13XNJM1LDuRrLcWdQQxuEcZ5TakypEk","Content-Type": "application/json"},encoding: Encoding.getByName('utf-8'));
    print("response: "+jsonEncode(json));
    print("response: "+response.body);
  }

  static void onCardClickedDetails(Event ev, BuildContext context, arg) async {
    final result = await Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context)
    => new DetailsEvent(ev, arg)));
    if(result == global.Constants.DELETE_SIGNAL) {
      //TODO delete
    }
    if(result == global.Constants.MODIFY_SIGNAL) {
      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context)
      => new EventCreator(ev)));
    }
  }
}
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}