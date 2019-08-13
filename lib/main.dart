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
import 'backdrop.dart';
import 'sign_in_vew.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentView = "/";//<--DEBUG MODE vista corrente
  String _role = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Calendar Demo',
      theme: customLightTheme,
      home: Backdrop(//<--DEBUG MODE vista corrente da cambiare con pagina di login
        frontLayerRoute: _currentView,
        backLayerRouteChanger: _onCategoryTap,
      ),
      routes: {
        //ROUTES COMMENTATE DELEGATE ALLA BACKDROP(AL FRONTLAYER DELLA BACKDROP)
        //'/calendar': (context) => DailyCalendar(title: "Home Calendar"),
        //'/list': (context) => SearchList(),
        //'/event_creator': (context) => EventCreator(null),
        '/reset_code_page': (context) => ResetCodePage("1235"),
        //'/profile': (context) => ProfilePage(),
        '/sign_in_page': (context) => SignInPage(),
      },
      onUnknownRoute: _getRoute,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    setState(() {
      _currentView = settings.name;
    });
    return MaterialPageRoute<void>(
    settings: settings,
    builder: (BuildContext context) =>
        Backdrop(
          frontLayerRoute: _currentView,
          backLayerRouteChanger: _onCategoryTap,
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
}


