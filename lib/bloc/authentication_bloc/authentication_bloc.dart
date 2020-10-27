import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/auth/authuser.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuthService _authenticationRepository;
  CloudFirestoreService _repository;
  StreamSubscription<AuthUser> _userSubscription;
  Account account = null;
  bool isSupervisor = false;
  String token = "";

  AuthenticationBloc({
    @required FirebaseAuthService authenticationRepository,
  })  : assert(authenticationRepository != null),
        _authenticationRepository = authenticationRepository,
        super(Uninitialized()) {
    _userSubscription = _authenticationRepository.onAuthStateChanged.listen(
        (user){if(user!=null) add(LoggedIn(user));},
      );
  }

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
    _repository = await CloudFirestoreService.create();
    try {
      var user = await _authenticationRepository.currentUser();
      if (user != null) {
        account = await _repository.getAccount(user.email);
        _repository.subscribeAccount(account.id).listen((userUpdate){ account.update(userUpdate);});
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
    var user = event.user;
    account = await _repository.getAccount(user.email);
    _repository.subscribeAccount(account.id).listen((userUpdate){ account.update(userUpdate);});
    isSupervisor = account.supervisor;
    token = account.token;
    if (PlatformUtils.platform == Constants.mobile || isSupervisor) yield Authenticated(account, isSupervisor, token);
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _authenticationRepository.signOut();
  }

  CloudFirestoreService getRepository(){
    if(state is Authenticated) return _repository;
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
