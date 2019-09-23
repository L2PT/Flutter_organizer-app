//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';

//run dependend by platform
//the actual main is in mobile.dart and/or web.dart
void main() {
  initializeDateFormatting("it_IT").then((_) => runApp(PlatformUtils.myApp));
}

