import 'dart:async';

import 'package:flutter/material.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/reset_auth_account/reset_auth_account_cubit.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';

class ResetAuthAccount extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    FirebaseAuthService authentication = context.repository<FirebaseAuthService>();
    CloudFirestoreService repository = context.repository<CloudFirestoreService>();

    Widget content = Scaffold(
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
                controller: context
                    .bloc<ResetAuthAccountCubit>()
                    .emailController,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Email",
                  suffixIcon: IconButton(
                      icon: Icon(Icons.email),
                      onPressed: context.bloc<ResetAuthAccountCubit>().sendEmailReset
                  ),
                ),
              ),
              Text("or", style: subtitle),
              TextField(
                controller: context
                    .bloc<ResetAuthAccountCubit>()
                    .phoneController,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Telefono",
                  suffixIcon: IconButton(
                      icon: Icon(Icons.phone_android),
                      onPressed: context.bloc<ResetAuthAccountCubit>().sendPhoneVerification
                  ),
                ),
              ),
              SizedBox(height: 50.0),
              PinFieldAutoFill(
                  controller: context.bloc<ResetAuthAccountCubit>().codeController,
                  decoration: UnderlineDecoration(
                      textStyle: TextStyle(fontSize: 20, color: Colors.black)),
                  onCodeSubmitted: context.bloc<ResetAuthAccountCubit>().checkCode,
                  codeLength: 6 //code length, default 6
              ),
              Spacer(),
              Divider(height: 10.0),
            ],
          ),
        )
    );

    Widget builder = BlocBuilder<ResetAuthAccountCubit, ResetAuthAccountState>(
      buildWhen: (previous, current) => current is CodeVerifiedState,
      builder: (context, state) {
      if(state is CodeVerifiedState){
        Timer(Duration(seconds: 3), () => context.bloc<MobileBloc>().add(NavigateEvent(Constants.homeRoute, null)));
        return LoadingScreen();
      } else return content;
      },
    );

    return new BlocProvider(
      create: (_) => ResetAuthAccountCubit(authentication, repository),
      child: MaterialApp(
        theme: ThemeData.light(),
        home: builder
      )
    );
  }
}