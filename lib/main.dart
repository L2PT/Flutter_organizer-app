//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/material.dart';
//import 'package:flutter_web/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'utils/theme.dart';
import 'event_creator.dart';
import 'daily_calendar_view.dart';
import 'operator_list.dart';
import 'reset_code_view.dart';
import 'user_profile.dart';
import 'sign_in_vew.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Calendar Demo',
      theme: customLightTheme,
      home: DailyCalendar(title:"Home Calendar"),
      routes: {
        '/calendar': (context) => DailyCalendar(title: "Home Calendar"),
        '/list': (context) => SearchList(),
        '/event_creator': (context) => EventCreator(null),
        '/reset_code_page': (context) => ResetCodePage("1235"),
        '/profile': (context) => ProfilePage(),
        '/sign_in_page': (context) => SignInPage(),
      },
    );
  }
}


