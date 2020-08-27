import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/views/backdrop.dart';
import 'package:venturiautospurghi/views/screen_pages/daily_calendar_view.dart';
import 'package:venturiautospurghi/views/screen_pages/log_in_view.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';
import 'package:venturiautospurghi/views/widgets/persistent_notification_widget.dart';
import 'package:venturiautospurghi/views/widgets/splash_screen.dart';
import 'bloc/authentication_bloc/authentication_bloc.dart';
import 'utils/theme.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(var context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is Unauthenticated) {
          return MaterialApp(
              title: Constants.title,
              theme: customLightTheme,
              debugShowCheckedModeBanner: false,
              home: LogIn());
        } else if (state is Authenticated) {
          CloudFirestoreService databaseRepository = CloudFirestoreService();
          return MaterialApp(
              title: Constants.title,
              theme: customLightTheme,
              debugShowCheckedModeBanner: false,
              home: RepositoryProvider.value(
                  value: databaseRepository,
                  child: BlocProvider(
                      create: (_) =>
                      MobileBloc(
                          account: context
                              .bloc<AuthenticationBloc>()
                              .account,
                          databaseRepository: databaseRepository)
                        ..add(InitAppEvent()),
                      child: BlocBuilder<MobileBloc, MobileState>(builder: (context, state) {
                        if (state is InBackdropState) {
                          return Backdrop();
                        } else if (state is OutBackdropState) {
                          return state.content;
                        } else if (state is NotificationWaitingState) {
                          return Stack(
                            children: <Widget>[
                              Scaffold(
                                  appBar: AppBar(
                                    leading: new IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.dehaze,
                                          color: white,
                                        )),
                                    title: new Text("HOME", style: title_rev),
                                  ),
                                  body: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      DailyCalendar(),
                                    ],
                                  )), Container(
                                decoration:
                                BoxDecoration(color: white.withOpacity(0.7)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    PersistentNotification(state.events)
                                  ],
                                ),
                              )
                            ],
                          );
                        }
                        return MaterialApp(
                            title: Constants.title,
                            theme: customLightTheme,
                            debugShowCheckedModeBanner: false,
                            home: SplashScreen());
                      },
                      )
                  )
              )
          );
        }
        return LoadingScreen();
      }
    );
  }
}