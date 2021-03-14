import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/auth/authuser.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:venturiautospurghi/repositories/firebase_messaging_service.dart';
import 'package:venturiautospurghi/utils/extensions.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuthService _authenticationRepository;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late CloudFirestoreService _dbRepository;
  late FirebaseMessagingService _msgRepository;
  Account? account;
  StreamSubscription<AuthUser?>? _userSubscription;
  StreamSubscription<Account>? _loginSubscription;
  bool isSupervisor = false;

  AuthenticationBloc({
    required FirebaseAuthService authenticationRepository,
  })  :  _authenticationRepository = authenticationRepository,
        super(Uninitialized()) {
    _userSubscription = _authenticationRepository.onAuthStateChanged.listen((user){
          if(user!=null) {
            if(state is Unauthenticated) add(LoggedIn(user));
          }
        },
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
    } else if (event is ResetAction) {
      yield* _mapResetActionToState(event);
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    _dbRepository = await CloudFirestoreService.create();
    _msgRepository = await FirebaseMessagingService.create();
    try {
      var user = await _authenticationRepository.currentUser();
      if (user != null) {
        account = await _dbRepository.getAccount(user.email);
        _loginSubscription = _dbRepository.subscribeAccount(account!.id).listen((userUpdate){ account!.update(userUpdate);});
        isSupervisor = account!.supervisor;
        yield Authenticated(account!, isSupervisor);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState(LoggedIn event) async* {
    var user = event.user;
    account = await _dbRepository.getAccount(user.email);
    _loginSubscription = _dbRepository.subscribeAccount(account!.id).listen((userUpdate){ account!.update(userUpdate);});
    isSupervisor = account!.supervisor;
    if (PlatformUtils.isMobile || isSupervisor) yield Authenticated(account!, isSupervisor, account!.tokens);
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    account = null;
    _authenticationRepository.signOut();
    _loginSubscription?.cancel();
  }

  Stream<AuthenticationState> _mapResetActionToState(ResetAction event) async* {
    yield Reset(event.email, event.phone);
  }

  CloudFirestoreService? getDbRepository(){
    if(state is Authenticated) return _dbRepository;
  }
  
  FirebaseMessagingService? getMsgRepository(){
    if(state is Authenticated) return _msgRepository;
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}

