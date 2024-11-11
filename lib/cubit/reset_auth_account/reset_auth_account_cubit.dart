import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/auth/email.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/utils/extensions.dart';

part 'reset_auth_account_state.dart';

class ResetAuthAccountCubit extends Cubit<ResetAuthAccountState>{
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final FirebaseAuthService _authenticationRepository;
  final CloudFirestoreService _databaseRepository;
  
  ResetAuthAccountCubit(FirebaseAuthService authenticationRepository, CloudFirestoreService databaseRepository, [String? autofilledEmail, String? autofilledPhone]) :
        _authenticationRepository = authenticationRepository, _databaseRepository = databaseRepository,
        super(AuthMethodSelectionState()){
    emailController.text = autofilledEmail??"";
    phoneController.text = autofilledPhone??"";
    // SmsAutoFill().listenForCode;
    // SmsAutoFill().code.listen((newCode) {
    //   checkCode(newCode);
    // });
  }

  void sendEmailReset([Email? email]){
    if(email == null) email = Email(emailController.value.toString());
    if(!email.validate()){
      return PlatformUtils.notifyErrorMessage("Account non trovato");
    } else {
      _authenticationRepository.sendPasswordReset(email.value);
      PlatformUtils.notifyInfoMessage("Mail per il ripristino della password inviata");
      emit(CodeVerifiedState());
    }
  }

  void sendPhoneVerification(){
    String phoneNumber = phoneController.value.toString();
    
    emit(CodeVerificationState(phoneNumber, "code"));
  }

  String generateCode(){
    String code = "";
    //TODO https://developers.google.com/identity/sms-retriever/verify
    return code;
  }

  void checkCode([String? codeSubmitted]) async {
    if(string.isNullOrEmpty(codeSubmitted)) codeSubmitted = codeController.value.toString();
    if(state is CodeVerificationState){
      if((state as CodeVerificationState).code == codeSubmitted) {
        sendEmailReset(await getEmailAddress((state as CodeVerificationState).phoneNumber));
      }
    }
  }

  Future<Email> getEmailAddress(String phoneNumber) async {
    Email address = Email((await _databaseRepository.getUserByPhone(phoneNumber)).email);
    return address;
  }
  
}
