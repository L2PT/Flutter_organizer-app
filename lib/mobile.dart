import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/plugins/firebase/firebase_messaging.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/views/backdrop.dart';
import 'package:venturiautospurghi/views/screen_pages/log_in_view.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';
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
    return MaterialApp(
      title: Constants.title,
      theme: customLightTheme,
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Unauthenticated) {
            return LogIn();
          } else if (state is Authenticated) {
            CloudFirestoreService databaseRepository = context.bloc<AuthenticationBloc>().getRepository();
            FirebaseMessagingService notificationService = FirebaseMessagingService(databaseRepository)
              ..init(context.bloc<AuthenticationBloc>().account, context);
            return RepositoryProvider.value(
                    value: databaseRepository,
                    child: BlocProvider(
                        create: (_) =>
                        MobileBloc(
                            account: context.bloc<AuthenticationBloc>().account,
                            databaseRepository: databaseRepository)..add(InitAppEvent()),
                        child: Stack(children: [
                          BlocBuilder<MobileBloc, MobileState>(
                            buildWhen: (previous, current) => current is InBackdropState,
                            builder: (context, state) => state is InBackdropState ?
                              Backdrop() : SplashScreen()
                          ),
                          BlocBuilder<MobileBloc, MobileState>(
                            buildWhen: (previous, current) => current is OutBackdropState ,
                            builder: (context, state) =>
                            (state is OutBackdropState && !state.isLeaving) ?
                              state.content : Container()
                          )
                        ],)
                    )
                );
          }
          return LoadingScreen();
        }
      ));
  }
}