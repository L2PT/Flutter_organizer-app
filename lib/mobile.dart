import 'dart:io' show Platform;
import 'package:fb_auth/fb_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:venturiautospurghi/view/details_event_view.dart';
import 'package:venturiautospurghi/view/splash_screen.dart';

import 'bloc/authentication_bloc/authentication_bloc.dart';
import 'bloc/backdrop_bloc/backdrop_bloc.dart';
import 'models/event.dart';
import 'utils/theme.dart';
import 'view/backdrop.dart';
import 'view/log_in_view.dart';

final tabellaUtenti = 'Utenti';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          title: 'Table Calendar Demo',
          theme: customLightTheme,
          debugShowCheckedModeBanner: false,
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state is Unauthenticated) {
                return LogIn();
              }else if (state is Authenticated) {
                return BlocProvider(
                    builder: (context) {
                      return BackdropBloc(state.user, state.isSupervisor)..dispatch(InitAppEvent());//dispatch(NavigateEvent(global.Constants.homeRoute,null));
                      },
                    child: Backdrop()
                );
              }
              return SplashScreen();
            },
          ),
    );
  }
}