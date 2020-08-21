import 'package:flutter/material.dart';

final logo = new Image.asset('assets/logo.png', height: 128.0);
final logo_web = new Image.asset('logo.png', height: 128.0);
final ThemeData customLightTheme = _buildTheme();
final title = TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: black, );
final subtitle = TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: grey_dark);
const title_rev = TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: white, );
final subtitle_rev = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: grey_light2);
final error = TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: red);
final label = TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: black);
final label_rev = TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: white);
final time_card = TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: white, );
final button_card = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: white, );
final title2 = TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: black );
final subtitle2 = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: grey );
final white_default = TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: white );

ThemeData _buildTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: yellow, //Colore secondario <-- da sistemare quando compare
    primaryColor: black, //appBar
    scaffoldBackgroundColor: whitebackground, //ok
    cardColor: Color(0x00000000),
    textSelectionColor: black,
    cursorColor: Color(0xFFFFFFFF),
    errorColor: red,
    buttonTheme: ButtonThemeData(
      buttonColor: black,
      textTheme: ButtonTextTheme.accent
    ),
    colorScheme: ColorScheme.dark().copyWith(secondary: black, secondaryVariant: black,),
    buttonBarTheme: ButtonBarThemeData(buttonTextTheme: ButtonTextTheme.accent,),
    hintColor: grey_light2,
    buttonColor: black,
    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0))),
        fillColor: black,

  ),
    textTheme: _buildShrineTextTheme(base.textTheme,black), //ok
    primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme,Color(0xFFFFFFFF)), //text appBar
    accentTextTheme: _buildShrineTextTheme(base.accentTextTheme,black), //Colore secondario <-- da sistemare quando compare
    iconTheme: IconThemeData(color: Color(0xFFF4F4F4)), //dunno
    primaryIconTheme: IconThemeData(color: Color(0xFFFFFFFF)) //icon
  );
}

TextTheme _buildShrineTextTheme(TextTheme base, Color c) {
  return base.copyWith(
    headline5: base.headline5.copyWith(
      fontWeight: FontWeight.w500,
    ),
    headline6: base.headline6.copyWith(
        fontSize: 18.0
    ),
    caption: base.caption.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14.0,
    ),
    bodyText1: base.bodyText1.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
    ),
  ).apply(
    fontFamily: 'Roboto',
    displayColor: black, //dunno
    bodyColor: c, //text

  );
}

const black_dark = const Color(0xFF000000);
const black = const Color(0xFF333333);
const black_light = const Color(0xFF4b4b4b);
const grey_dark = const Color(0xFFA8A8A8);
const grey = const Color(0xFFA3A3A3);
const grey_light = const Color(0xFFDDDDDD);
const grey_light2 = const Color(0xFFF4F4F4);
const white = const Color(0xFFFFFFFF);
const whitebackground = const Color(0xFFFFFFFF); //background
const whiteoverlapbackground = const Color(0x99FFFFFF); //overlap background
const red = const Color(0xFFC5032B);
const yellow = const Color(0xFFF8AD09);
const blue = const Color(0xFF119DD1);
const green = const Color(0xFF00664D);