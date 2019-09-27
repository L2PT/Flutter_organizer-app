library App.utils;

import 'package:flutter/material.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;

class Utils {
  static Color getColor(arg) {
    Map <String,dynamic> categories;
    var docRef = PlatformUtils.fire.collection("Costanti").document("Categorie");
    docRef.get().then((doc) {
      if (doc.exists) {
        categories = doc.data;
        categories['default'] = global.Constants.fallbackHexColor;
      } else {
        print("No categories!");
      }
    }).catchError((error) {
      print("Error getting categories: "+error);
    });
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