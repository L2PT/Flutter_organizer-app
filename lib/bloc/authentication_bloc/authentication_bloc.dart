import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/auth/authuser.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/repositories/firebase_messaging_service.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuthService _authenticationRepository;
  late CloudFirestoreService _dbRepository;
  late FirebaseMessagingService _msgRepository;
  Account? account;
  StreamSubscription<AuthUser?>? _userSubscription;
  StreamSubscription<Account>? _loginSubscription;
  bool isSupervisor = false;

  AuthenticationBloc({
    required FirebaseAuthService authenticationRepository,
    required CloudFirestoreService dbCloudFirestore,
    required FirebaseMessagingService messagingService,
  }) :  _authenticationRepository = authenticationRepository,
      _msgRepository = messagingService,
      _dbRepository = dbCloudFirestore,
        super(Uninitialized())  {
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
    }else if (event is NotUpdateApp){
      yield Unavailable();
    }else if (event is UpdateApp){
      yield* _mapAppUpdateToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    int numVersionApp =  await PlatformUtils.getVersionApp() ;
    int numBuildApp =  await PlatformUtils.getNumBuildApp();
    _dbRepository.getInfoApp().listen((infoApp)  {
      bool checkVersion = false;
      int numVersionDB = 0;
      var version = infoApp["Versione"].toString();
      var numBuild = int.parse(infoApp["NumBuild"].toString());
      version.split(".").forEach((numDB) {
        numVersionDB += int.parse(numDB);
      });
      if(numVersionDB > numVersionApp){
        checkVersion = true;
        add(NotUpdateApp());
      }
      if(!checkVersion && numBuild > numBuildApp) {
        checkVersion = true;
        add(NotUpdateApp());
      }
      if(!checkVersion){
        add(UpdateApp());
      }
    });
  }

  Stream<AuthenticationState> _mapAppUpdateToState() async* {
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
    String? token = await FirebaseMessagingService.getToken();
    if(token != null) {
      if (account!.tokens.contains(token)) {
        account!.tokens.remove(token);
        _dbRepository.updateAccountField(account!.id, "Tokens", account!.tokens);
      }
    }
    account = null;
    _authenticationRepository.signOut();
    _loginSubscription?.cancel();
  }

  Stream<AuthenticationState> _mapResetActionToState(ResetAction event) async* {
    yield Reset(event.email, event.phone);
  }

  CloudFirestoreService? getDbRepository(){
    return _dbRepository;
  }
  
  FirebaseMessagingService? getMsgRepository(){
    return _msgRepository;
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}

