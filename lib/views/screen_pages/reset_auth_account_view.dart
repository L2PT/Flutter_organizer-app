import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/cubit/reset_auth_account/reset_auth_account_cubit.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';

class ResetAuthAccount extends StatelessWidget {
  final String _autofilledEmail;
  final String _autofilledPhone;
  const ResetAuthAccount(this._autofilledEmail, this._autofilledPhone);

  @override
  Widget build(BuildContext context) {
    FirebaseAuthService authentication = context.read<FirebaseAuthService>();
    CloudFirestoreService repository = context.read<CloudFirestoreService>();
    
    Widget builder = BlocBuilder<ResetAuthAccountCubit, ResetAuthAccountState>(
      buildWhen: (previous, current) => current is CodeVerifiedState,
      builder: (context, state) {
      if(state is CodeVerifiedState){
        Timer(Duration(seconds: 3), () => PlatformUtils.navigator(context, Constants.homeRoute));
        return LoadingScreen();
      } else return _resetAuthContent();
      },
    );

    return new BlocProvider(
      create: (_) => ResetAuthAccountCubit(authentication, repository, _autofilledEmail, _autofilledPhone),
      child: MaterialApp(
        theme: ThemeData.light(),
        home: builder
      )
    );
  }
}

class _resetAuthContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: (){ context.read<AuthenticationBloc>().add(AppStarted()); return Future<bool>(()=>false); },
        child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 10.0),
              TextField(
                controller: context.read<ResetAuthAccountCubit>().emailController,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Email",
                  suffixIcon: IconButton(
                      icon: Icon(Icons.email),
                      onPressed: context.read<ResetAuthAccountCubit>().sendEmailReset
                  ),
                ),
              ),
              Text("or", style: subtitle),
              TextField(
                controller: context.read<ResetAuthAccountCubit>().phoneController,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Telefono",
                  suffixIcon: IconButton(
                      icon: Icon(Icons.phone_android),
                      onPressed: context.read<ResetAuthAccountCubit>().sendPhoneVerification
                  ),
                ),
              ),
              SizedBox(height: 50.0),
              Spacer(),
              Divider(height: 10.0),
            ],
          ),
        )
      )
    );
  }
}
