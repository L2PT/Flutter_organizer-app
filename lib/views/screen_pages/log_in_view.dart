import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/cubit/login_cubit.dart';
import 'file:///C:/Users/Gio/Desktop/Flutter_organizer-app/lib/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/base_alert.dart';
import 'package:venturiautospurghi/views/widgets/delete_alert.dart';
import 'package:venturiautospurghi/views/widgets/responsive_widget.dart';

class LogIn extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var repository = RepositoryProvider.of<FirebaseAuthService>(context);

    Widget content = Padding(
      padding: EdgeInsets.only(left: 24.0, right: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          logo,
          _emailInput(),
          SizedBox(height: 8.0),
          _passwordInput(),
          SizedBox(height: 8.0),
          _errorText(),
          SizedBox(height: 8.0),
          _loginButton(),
          SizedBox(height: 30.0),
          _resetPasswordText(),
        ],
      ),
    );

    Widget loginPage = Container(
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery
                .of(context)
                .size
                .height / 8,
            width: double.infinity,
            color: black,
            child: CustomPaint(
                painter: PathPainter(),
                child: Container()
            ),
          ), SizedBox(height: 10.0,), ResponsiveWidget(
              largeScreen: Align(alignment: Alignment.topCenter,
                child: Container(
                  width: 1000,
                  child: content,
                ),),
              smallScreen: content
          )
        ],
      ),
    );

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: white,
      body: new BlocProvider(
          create: (_) => LoginCubit(repository),
          child: loginPage
      ),
    );
  }
}

class _emailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        children: <Widget>[
          new Padding(
            padding:
            EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Icon(
              Icons.person_outline,
              color: Colors.grey,
            ),
          ),
          Container(
            height: 30.0,
            width: 1.0,
            color: Colors.grey.withOpacity(0.5),
            margin: const EdgeInsets.only(left: 00.0, right: 10.0),
          ),
          new Expanded(
            child: TextField(
              cursorColor: black,
              textInputAction: TextInputAction.next,
              onChanged: (email) => context.bloc<LoginCubit>().emailChanged(email),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Inserisci l\'indirizzo email',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _passwordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin:
      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        children: <Widget>[
          new Padding(
            padding:
            EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Icon(
              Icons.lock_open,
              color: Colors.grey,
            ),
          ),
          Container(
            height: 30.0,
            width: 1.0,
            color: Colors.grey.withOpacity(0.5),
            margin: const EdgeInsets.only(left: 00.0, right: 10.0),
          ),
          new Expanded(
            child: TextField(
              cursorColor: black,
              textInputAction: TextInputAction.done,
              onChanged: (password) => context.bloc<LoginCubit>().passwordChanged(password),
              obscureText: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Inserisci la password',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _errorText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.isLoading(),
      builder: (context, state) {
        if(state.isEmailInvalid()) return Text("L'email inserita non è valida", style: error,);
        if(state.isPasswordInvalid()) return Text("La password inserita non è valida", style: error,);
        if(state.isSuccess()) return Text("Accesso effettuato. Attendere reindirizzamento...", style: subtitle2,);
        if(state.isFailure()) return Text("Le credenziali inserite non sono valide", style: error,);
        return Text("");
      },
    );
  }
}

class _loginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.isLoading()
            ? loadingSpinner :
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: FlatButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      color: black,
                      child: new Row(
                        children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Text(
                              "LOGIN",
                              style: TextStyle(color: white),
                            ),
                          ),
                          new Expanded(
                            child: Container(),
                          ),
                          new Transform.translate(
                            offset: Offset(10.0, 0.0),
                            child: new Container(
                              padding: const EdgeInsets.all(5.0),
                              child: FlatButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                    new BorderRadius.circular(45.0)),
                                color: white,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: black,
                                ),
                                onPressed: (){FocusScope.of(context).unfocus();context.bloc<LoginCubit>().logInWithCredentials();}
                              ),
                            ),
                          )
                        ],
                      ),
                        onPressed: (){FocusScope.of(context).unfocus();context.bloc<LoginCubit>().logInWithCredentials();}
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  final loadingSpinner = new Center(
    heightFactor: null,
    widthFactor: null,
    child: new CircularProgressIndicator(),
  );

}

class _resetPasswordText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var blocState = context.bloc<LoginCubit>().state;
        String resetMessage;
        if (blocState.email.value?.isNullOrEmpty()??false) {
          resetMessage = 'Inserisci un indirizzo email';
        } else {
          resetMessage = 'Reset password per ' + blocState.email.value;
          resetMessage += ". Manda all'altra view o un identificativo dell'utente o già mail e telefono in modo che i campi siano già compilati";
        }

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return new Alert(
                title: "RESET PASSWORD",
                content: new Text(resetMessage, style: label,),
                action: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: new Text('ANNULLA', style: label),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                      SizedBox(width: 15,),
                      RaisedButton(
                        child: new Text('CONFERMA', style: button_card),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15.0))),
                        color: black,
                        elevation: 15,
                        onPressed: () {
                          if (!blocState.email.value.isNullOrEmpty()) {
                            context.bloc<MobileBloc>().add(NavigateEvent(Constants.resetCodeRoute));
                          }
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ]),
              );
            }
        );
      },
      child: new Text('Reset Password', textAlign: TextAlign.center,
        style: new TextStyle(fontSize: 18.0, color: Colors.black54),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  int span = -1;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, size.height - span);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height - span);
    canvas.drawPath(path, paint);
    if (span > 0) canvas.drawRect(Rect.fromLTRB(0, size.height - span, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}