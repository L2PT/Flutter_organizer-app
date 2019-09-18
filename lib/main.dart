//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_web/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'utils/theme.dart';
import 'event_creator.dart';
import 'daily_calendar_view.dart';
import 'operator_list.dart';
import 'reset_code_view.dart';
import 'user_profile.dart';
import 'backdrop.dart';
import 'event_view.dart';
import 'log_in_view.dart';

void main() {
  initializeDateFormatting("it_IT").then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentView = "/";//<--DEBUG MODE vista corrente
  Object _currentArg = null;
  bool _isSupervisor = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Calendar Demo',
      theme: customLightTheme,
      debugShowCheckedModeBanner: false,
      home:Backdrop(frontLayerRoute: _currentView,
        frontLayerArg: _currentArg,
        backLayerRouteChanger: _onCategoryTap,
        isSupervisor: _isSupervisor
      ),
      routes: {
        //ROUTES COMMENTATE DELEGATE ALLA BACKDROP(AL FRONTLAYER DELLA BACKDROP)
        //'/calendar': (context) => DailyCalendar(title: "Home Calendar"),
        //'/op_list': (context) => SearchList(),
        //'/event_creator': (context) => EventCreator(null),
        '/reset_code_page': (context) => ResetCodePage("1235"),
        //'/profile': (context) => ProfilePage(),
        '/log_in_page': (context) => LogInPage(_onLogin),
      },
      onUnknownRoute: _getRoute,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    print(settings);
    print("main");
    setState(() {
      _currentView = settings.name;
      _currentArg = settings.arguments;
    });
    return MaterialPageRoute<void>(
    settings: settings,
    builder: (BuildContext context) =>
        Backdrop(
          frontLayerRoute: _currentView,
          frontLayerArg: _currentArg,
          backLayerRouteChanger: _onCategoryTap,
          isSupervisor: _isSupervisor,
        ),
    fullscreenDialog: true,
    );
  }

  /// Function to call when a [Category] is tapped.
  void _onCategoryTap(String route) {
    setState(() {
      _currentView = route;
    });
  }
  /// Function to setup the user
  void _onLogin(bool isSupervisor) {
    setState(() {
      _isSupervisor = isSupervisor;
    });
  }
}


