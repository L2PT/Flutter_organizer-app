import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/plugins/firebase/firebase_messaging.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/views/backdrop.dart';
import 'package:venturiautospurghi/views/screen_pages/daily_calendar_view.dart';
import 'package:venturiautospurghi/views/screen_pages/log_in_view.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';
import 'file:///C:/Users/Gio/Desktop/Flutter_organizer-app/lib/views/screens/persistent_notification_widget.dart';
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
          FirebaseMessagingService notificationService = FirebaseMessagingService(databaseRepository)
            ..init(context.bloc<AuthenticationBloc>().account, context);
          return MaterialApp(
              title: Constants.title,
              theme: customLightTheme,
              debugShowCheckedModeBanner: false,
              home: RepositoryProvider.value(
                  value: databaseRepository,
                  child: BlocProvider(
                      create: (_) =>
                      MobileBloc(
                          account: context.bloc<AuthenticationBloc>().account,
                          databaseRepository: databaseRepository)..add(InitAppEvent()),
                      child: BlocBuilder<MobileBloc, MobileState>(builder: (context, state) {
                        if (state is InBackdropState) {
                          return Backdrop();
                        } else if (state is OutBackdropState) {
                          return state.content;
                        } else if (state is NotificationWaitingState) {
                          return PersistentNotification();
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