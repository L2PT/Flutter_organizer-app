import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegisterState();
}

///
/// This class would require a cubit like for [log_in_view.dart]
/// but it's preferred the use of a form since we don't have an entangled state and the actions are called in the repository
///
class RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _codFiscaleController = TextEditingController();
  int _radioValue = 0;
  bool _success;
  String _successMessage = "";
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          _onBackPressed();
          return Future<bool>.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: new BackButton(
              onPressed: _onBackPressed,
            ),
            title: new Text('CREAZIONE UTENTE', style: title_rev),
          ),
          body: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(6.0),
                child: Icon(
                  Icons.work,
                  color: yellow,
                  size: 70,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: black,
                ),
              ),
              SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      cursorColor: black,
                      controller: _nomeController,
                      decoration: InputDecoration(
                        hintText: "Nome",
                        hintStyle: subtitle,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Il campo \'Nome\' è obbligatorio';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _cognomeController,
                      cursorColor: black,
                      decoration: InputDecoration(
                        hintText: 'Cognome',
                        hintStyle: subtitle,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Il campo \'Cognome\' è obbligatorio';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      cursorColor: black,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: subtitle,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Il campo \'Email\' è obbligatorio';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                        controller: _telefonoController,
                        cursorColor: black,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Telefono',
                          hintStyle: subtitle,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Il campo \'Telefono\' è obbligatorio';
                          } else if (!Utils.isNumeric(value)) {
                            return 'Inserisci un valore valido';
                          }
                          return null;
                        }),
                    TextFormField(
                      controller: _codFiscaleController,
                      cursorColor: black,
                      decoration: InputDecoration(
                        hintText: 'Codice Fiscale',
                        hintStyle: subtitle,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Il campo \'Codice Fiscale\' è obbligatorio';
                        } else if (value.length != 16) {
                          return 'Inserisci un valore valido';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => _handleRadioValueChanged(Role.Operatore),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: (_radioValue == 0) ? black : white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: grey)),
                                padding: EdgeInsets.only(right: 10),
                                child: Row(children: <Widget>[
                                  new Radio(
                                    value: 0,
                                    activeColor: black_light,
                                    groupValue: _radioValue,
                                    onChanged: _handleRadioValueChanged,
                                  ),
                                  new Text('Operatore',
                                      style: (_radioValue == Role.Operatore) ? subtitle_rev : subtitle.copyWith(color: black)),
                                ])),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          GestureDetector(
                            onTap: () => _handleRadioValueChanged(Role.Reponsabile),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: (_radioValue == 1) ? black : white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: grey)),
                                padding: EdgeInsets.only(right: 10),
                                child: Row(children: <Widget>[
                                  new Radio(
                                    value: 1,
                                    activeColor: black_light,
                                    groupValue: _radioValue,
                                    onChanged: _handleRadioValueChanged,
                                  ),
                                  new Text('Responsabile',
                                      style: (_radioValue == Role.Reponsabile) ? subtitle_rev : subtitle.copyWith(color: black)),
                                ])),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(
                              child: new Text('Annulla', style: label),
                              onPressed: _onBackPressed,
                            ),
                            SizedBox(width: 20),
                            RaisedButton(
                              color: black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  _register();
                                }
                              },
                              child: Text('CONFERMA', style: title_rev),
                            ),
                          ],
                        )),
                    Container(
                      alignment: Alignment.center,
                      child: Text(_success == null ? '' : (_success ? _successMessage : _errorMessage),
                        style: _success != null && _success ? label : error,
                      ),
                    )
                  ],
                ),
              ),
            ]),
          )),
        ));
  }

  Future<bool> _onBackPressed() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.bloc<MobileBloc>().add(NavigateEvent(Constants.homeRoute, null));
    }
  }

  void _handleRadioValueChanged(int value) {
    setState(() {
      _radioValue = value;
    });
  }

  void _register() async {
    RepositoryProvider.of<FirebaseAuthService>(context).createAccount(
      _emailController.text,
      Constants.passwordNewUsers,
      displayName: _cognomeController.text + " " + _nomeController.text,
    ).then((user) {
      if (user != null) {
        Account newlyCreated = Account(user.uid, _nomeController.text, _cognomeController.text, _emailController.text,
            _telefonoController.text, _codFiscaleController.text, [], "", _radioValue == Role.Reponsabile);
        context.repository<CloudFirestoreService>().addOperator(newlyCreated);
        context.repository<FirebaseAuthService>().sendPasswordReset(_emailController.text);
        setState(() {
          _success = true;
          _successMessage = "Utente " + user.email + " registrato con successo.";
          _errorMessage = "";
          Timer(Duration(seconds: 3),
              () => context.bloc<MobileBloc>().add(NavigateEvent(Constants.homeRoute, null)));
        });
      } else {
        setState(() {
          _success = false;
          _errorMessage = "Creazione account fallita";
          _successMessage = "";
        });
      }
    }).catchError((e) {
      setState(() {
        _success = false;
        _errorMessage = e.toString().split(",")[1];
        _successMessage = "";
      });
    });
  }

}

class Role { static const Operatore = 0, Reponsabile = 1; }
