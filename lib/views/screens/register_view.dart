import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
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

  @override
  Widget build(BuildContext context) {    
    return WillPopScope(
        onWillPop: ()=>PlatformUtils.backNavigator(context),
        child: Scaffold(
          appBar: AppBar(
            leading: new BackButton(
              onPressed: (){ PlatformUtils.backNavigator(context); },
            ),
            title: new Text('CREAZIONE UTENTE', style: title_rev),
          ),
          body: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(6.0),
                child: Icon(
                  FontAwesomeIcons.hardHat,
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
                      validator: (value) => string.isNullOrEmpty(value)?
                        'Il campo \'Nome\' è obbligatorio' : null
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
                      validator: (value) => string.isNullOrEmpty(value)?
                        'Il campo \'Cognome\' è obbligatorio' : null
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
                      validator: (value) => string.isNullOrEmpty(value)?
                        'Il campo \'Email\' è obbligatorio' : null
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
                        validator: (value) => string.isNullOrEmpty(value)?
                          'Il campo \'Telefono\' è obbligatorio' : !Utils.isPhoneNumber(value!)?
                          'Inserisci un valore valido' : null
                    ),
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
                      validator: (value) => string.isNullOrEmpty(value) || value!.length != 16?
                        'Il campo \'Codice Fiscale\' è obbligatorio' : null
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
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
                            TextButton(
                              child: new Text('Annulla', style: label),
                              onPressed:  (){ PlatformUtils.backNavigator(context); },
                            ),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _register();
                                }
                              },
                              child: Text('CONFERMA', style: title_rev),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ]),
          )),
        ));
  }

  void _handleRadioValueChanged(int? value) {
    if(value != null)
      setState(() {
        _radioValue = value;
      });
  }

  void _register() async {
    FocusScope.of(context).unfocus();
    context.read<FirebaseAuthService>().createAccount(
      _emailController.text,
      Constants.passwordNewUsers,
      displayName: _cognomeController.text + " " + _nomeController.text,
    ).then((userFirebase) {
      if (userFirebase.user != null) {
        Account newlyCreated = Account(userFirebase.user!.uid, _nomeController.text, _cognomeController.text, _emailController.text.toLowerCase(),
            _telefonoController.text, _codFiscaleController.text, [], [], _radioValue == Role.Reponsabile);
        context.read<CloudFirestoreService>().addOperator(newlyCreated);
        context.read<FirebaseAuthService>().sendPasswordReset(_emailController.text);
        setState(() {
          PlatformUtils.notifyInfoMessage( "Utente  ${userFirebase.user!.email} registrato con successo.");
          Timer(Duration(seconds: 2), () => PlatformUtils.backNavigator(context));
        });
      } else {
        setState(() {
          PlatformUtils.notifyErrorMessage("Creazione account fallita");
        });
      }
    }).catchError((e) {
      setState(() {
        PlatformUtils.notifyErrorMessage(e.code == 'email-already-in-use'?"Esiste già un account associato a questa mail.":e.toString());
      });
    }).timeout(Duration(seconds: 10), onTimeout: (){
        setState(() {
        PlatformUtils.notifyErrorMessage("Creazione account fallita");
      });
    });
  }

}

class Role { static const Operatore = 0, Reponsabile = 1; }
