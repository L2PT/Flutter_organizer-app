import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fb_auth/fb_auth.dart';
import 'package:venturiautospurghi/plugin/dispatcher/mobile.dart';
import 'package:flutter/material.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FBAuth _userRepository = FBAuth();
  AuthUser user = null;
  bool isSupervisor = false;

  AuthenticationBloc();

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      user = await _userRepository.currentUser();
      if (user != null) {
        isSupervisor = await getSupervisorFlag(user.email);
        yield Authenticated(user, isSupervisor);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    user = await _userRepository.currentUser();
    isSupervisor = await getSupervisorFlag(user.email);
    yield Authenticated(user, isSupervisor);
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _userRepository.logout();
  }

  Future<bool> getSupervisorFlag(String email) async {
    var docs = await PlatformUtils.fire.collection("Utenti").where('Email',isEqualTo: email).getDocuments();
    for (var doc in docs.documents) {
      if(doc != null) {
        return doc.data['Responsabile'];
      }
    }
  }
}
