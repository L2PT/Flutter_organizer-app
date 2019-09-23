import 'dart:io' show Platform;
import 'package:fb_auth/fb_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;

import 'utils/theme.dart';
import 'reset_code_view.dart';
import 'backdrop.dart';
import 'log_in_view.dart';

final _auth = FBAuth();
final tabellaUtenti = 'Utenti';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentView = "/";//<--DEBUG MODE vista corrente
  Object _currentArg = null;
  bool _isLoggedIn = null;
  bool _isSupervisor = false;

  @override
  void initState() {
    _onLogin(null);
  }

  @override
  Widget build(BuildContext context) {
    //(1)-App init injection and routes standard
    return MaterialApp(
      title: 'Table Calendar Demo',
      theme: customLightTheme,
      debugShowCheckedModeBanner: false,
      home: Backdrop(frontLayerRoute: _currentView,
          frontLayerArg: _currentArg,
          backLayerRouteChanger: _onCategoryTap,
          isLoggedIn: _isLoggedIn,
          isSupervisor: _isSupervisor
      ),
      routes: {
        '/reset_code_page': (context) => ResetCodePage("1235"),
        '/log_in_page': (context) => LogInPage(_onLogin),
      },
      onUnknownRoute: _getRoute,
    );
  }

  /// Function that resolves the route not standard for Android.
  /// It pass the route and the arguments to the Backdrop that will present the page
  Route<dynamic> _getRoute(RouteSettings settings) {
    //(2)-if route not standard it goes here
    //get route and arguments (not standard)
    setState(() {
      _currentView = settings.name;
      _currentArg = settings.arguments;
    });
    //return backdrop and pass it route and arguments to resolve
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) =>
          Backdrop(
            frontLayerRoute: _currentView,
            frontLayerArg: _currentArg,
            backLayerRouteChanger: _onCategoryTap,
            isLoggedIn: _isLoggedIn,
            isSupervisor: _isSupervisor,
          ),
      fullscreenDialog: true,
    );
  }

  /// Function to call when a [Category] is tapped.
  void _onCategoryTap(String route) {
    if(route == global.Constants.logOut) {
      _onLogout();
      setState(() {
        _isLoggedIn = false; //this tells the backdrop to navigate to login page
      });
    }else{
      setState(() {
        _currentView = route; //this tells the backdrop to navigate to login page
      });
    }
  }

  /// Function to setup the user
  void _onLogin(AuthUser user) async {
    bool isSupervisor = false;
    if(user == null){
      //check status and get role
      user = await _auth.currentUser();
      if(user == null){
        //go to the login page (you can't do it from here)
        setState(() {
          _isLoggedIn = false; //this tells the backdrop to navigate to login page
        });
        return;
      }
    }
    //you are logged in, get role
    QuerySnapshot documents = (await Firestore.instance.collection(tabellaUtenti).where('Email',isEqualTo: user.email).getDocuments());
    for (DocumentSnapshot document in documents.documents) {
      if(document != null) {
        isSupervisor = document.data['Responsabile'];
        setState(() {
          _isSupervisor = isSupervisor;
          _isLoggedIn = true; //this tells the backdrop to stop loading
        });
        break;
      }
    }
  }

  void _onLogout() async {
    await _auth.logout();
    Navigator.of(context).pushReplacementNamed(global.Constants.logInRoute);
  }
}


