import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF" + hexColor;
      }
      return int.parse(hexColor, radix: 16);
    } catch (e){
      return _getColorFromHex(Constants.fallbackHexColor);
    }
  }
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}