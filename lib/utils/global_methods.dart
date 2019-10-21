library App.utils;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:http/http.dart' as http;

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

  static void notify({token="eGIwmXLpg_c:APA91bGkJI5Nargw6jjiuO9XHxJYcJRL1qfg0CjmnblAsZQ8k-kPQXCCkalundHtsdS21_clryRplzXaSgCj6PM1geEmXttijdSCWQuMQWUHpjPZ9nJOaNFqC6Yq6Oa5WixzyObXr8gt",
                      descrizione="Clicca la notifica per vedere i dettagli",
                      evento="40OeLLC50mmRuS4DLdJU"}) async {
    String url = "https://fcm.googleapis.com/fcm/send";
    String json = "";
    Map<String,String> not = new Map<String,String>();
    Map<String,String> data = new Map<String,String>();
    json = "{\"to\":\"${token}\",";
    not['title'] = "Nuovo incarico assegnato";
    not['body'] = descrizione;
    not['click_action'] = "FLUTTER_NOTIFICATION_CLICK";
    data['id'] = evento;
    json += "\"notification\":"+jsonEncode(not)+", \"data\":"+jsonEncode(data)+"}";
    var response = await http.post(url, body: json, headers: {"Authorization": "key=AIzaSyBF13XNJM1LDuRrLcWdQQxuEcZ5TakypEk","Content-Type": "application/json"},encoding: Encoding.getByName('utf-8'));
    print("response: "+jsonEncode(json));
    print("response: "+response.body);
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