import 'package:flutter/material.dart';

class LinkMenu {

  final IconData _icon;
  final Color  _color;
  final double _size;
  final String _text;
  final TextStyle _style;

  const LinkMenu(this._icon, this._color, this._size, this._text, this._style);

  IconData get iconLink => _icon;
  String get textLink => _text;
  Color get colorIcon => _color;
  TextStyle get styleText => _style;
  double get sizeIcon => _size;

}