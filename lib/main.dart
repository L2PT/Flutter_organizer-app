//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'bloc/authentication_bloc/authentication_bloc.dart';
import 'bloc/simple_bloc_delegate.dart';

//run dependend by platform
//the actual main is in mobile.dart and/or web.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseAuthService authenticationRepository;
  Bloc.observer = SimpleBlocObserver();
  Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyD3A8jbx8IRtXvnmoGSwJy2VyRCvo0yjGk",
        authDomain: "com-l2pt-venturiautospurghi.firebaseapp.com",
        databaseURL: "https://com-l2pt-venturiautospurghi.firebaseio.com",
        projectId: "com-l2pt-venturiautospurghi",
        storageBucket: "com-l2pt-venturiautospurghi.appspot.com",
        messagingSenderId: "964614131015",
        appId: "1:964614131015:web:8a10af66f5b15bad589062"
    )).then((_) => initializeDateFormatting("it_IT"))
      .then((_) {
        authenticationRepository = FirebaseAuthService();
        runApp(
          RepositoryProvider.value(
            value: authenticationRepository,
            child: BlocProvider(
                create: (_) => AuthenticationBloc(
                  authenticationRepository: authenticationRepository,
                )..add(AppStarted()),
                child: PlatformUtils.myApp),
          ),
        );
  }).then((_) => PlatformUtils.initDownloader());
}
