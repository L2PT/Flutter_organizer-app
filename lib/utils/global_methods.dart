library App.utils;

import 'package:flutter/material.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;

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

  static String formatDateString(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;

    return year.toString() + '-' + ((month/10<1)?"0"+month.toString():month.toString()) + '-' + ((day/10<1)?"0"+day.toString():day.toString());
  }
  static DateTime formatDate(DateTime date) {
    return DateTime.parse(formatDateString(date));
  }
  static bool isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
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