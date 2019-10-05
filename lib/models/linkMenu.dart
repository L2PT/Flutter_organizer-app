import 'package:flutter/material.dart';

class LinkMenu {

  final IconData iconLink;
  final Color  colorIcon;
  final double sizeIcon;
  final String textLink;
  final TextStyle styleText;

  const LinkMenu(this.iconLink, this.colorIcon, this.sizeIcon, this.textLink, this.styleText);

  IconData get icon => iconLink;
  String get text => textLink;
  Color get color => colorIcon;
  TextStyle get style => styleText;
  double get size => sizeIcon;

}