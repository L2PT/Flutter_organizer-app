import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fb_auth/fb_auth.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:flutter/material.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FBAuth _userRepository = FBAuth();
  AuthUser user = null;
  Account account = null;
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
      yield* _mapLoggedInToState(event);
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      user = await _userRepository.currentUser();
      if (user != null) {
        account = await getAccount(user.email);
        isSupervisor = account.supervisor;
        yield Authenticated(account, isSupervisor);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState(LoggedIn event) async* {
    user = event.user;
    account = await getAccount(user.email);
    isSupervisor = account.supervisor;
    yield Authenticated(account, isSupervisor);
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _userRepository.logout();
  }

  Future<Account> getAccount(String email) async {
    var docs = await PlatformUtils.waitFireCollection("Utenti",whereCondFirst:'Email', whereOp: "==", whereCondSecond: email);
    for (var doc in docs) {
      if(doc != null) {
        return Account.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), PlatformUtils.extractFieldFromDocument(null, doc));
      }
    }
  }
}
