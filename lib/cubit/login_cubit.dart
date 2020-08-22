import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:venturiautospurghi/models/auth/email.dart';
import 'package:venturiautospurghi/models/auth/password.dart';
import 'package:venturiautospurghi/plugins/firebase/firebase_auth_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository)
      : assert(_authenticationRepository != null),
        super(const LoginState());

  final FirebaseAuthService _authenticationRepository;

  void emailChanged(String value) {
    final email = Email(value);
    emit(state.assign(
      email: email
    ));
  }

  void passwordChanged(String value) {
    final password = Password(value);
    emit(state.assign(
        password: password
    ));
  }

  Future<void> logInWithCredentials() async {
    if (state.isInvalid()) return;
    var stateToRestore = state;
    emit(state.assign(status: FormStatus.loading));
    if(stateToRestore.isValid()) {
      try {
        await _authenticationRepository.signInWithEmailAndPassword(
          state.email.value,
          state.password.value,
        );
        emit(state.assign(status: FormStatus.success));
      } on Exception {
        emit(state.assign(status: FormStatus.failure));
      }
    } else{
      emit(state.assign(status: stateToRestore.status));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.assign(status: FormStatus.loading));
    try {
      await _authenticationRepository.signInWithGoogle();
      emit(state.assign(status: FormStatus.success));
    } on Exception {
      emit(state.assign(status: FormStatus.failure));
    }
  }
}
