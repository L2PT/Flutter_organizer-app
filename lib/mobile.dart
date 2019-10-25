import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/view/details_event_view.dart';
import 'package:venturiautospurghi/view/form_event_creator_view.dart';
import 'package:venturiautospurghi/view/splash_screen.dart';
import 'bloc/authentication_bloc/authentication_bloc.dart';
import 'bloc/backdrop_bloc/backdrop_bloc.dart';
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
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is Unauthenticated) {
          return MaterialApp(
              title: global.Constants.title,
              theme: customLightTheme,
              debugShowCheckedModeBanner: false,
              home: LogIn()
          );
        }else if (state is Authenticated) {
          return MaterialApp(
              title: global.Constants.title,
              theme: customLightTheme,
              debugShowCheckedModeBanner: false,
              home: BlocProvider(
                  builder: (context) {
                    return BackdropBloc(state.user, state.user.supervisor)..dispatch(InitAppEvent());
                  },
                  child: Backdrop()
              ),
              routes: {
                global.Constants.detailsEventViewRoute: (context){
                    final dynamic args = ModalRoute.of(context).settings.arguments;
                    return DetailsEvent(args);
                },
                global.Constants.formEventCreatorRoute: (context){
                  final dynamic args = ModalRoute.of(context).settings.arguments;
                  return EventCreator(args);
                },
              }
          );
        }
        return MaterialApp(
            title: global.Constants.title,
            theme: customLightTheme,
            debugShowCheckedModeBanner: false,
            home: SplashScreen()
        );
      },
    );
  }
}

