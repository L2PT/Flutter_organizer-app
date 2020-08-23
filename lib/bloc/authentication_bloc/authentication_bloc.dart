import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/auth/authuser.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuthService _authenticationRepository;
  StreamSubscription<AuthUser> _userSubscription;
  Account account = null;
  bool isSupervisor = false;

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
    try {
      var user = await _authenticationRepository.currentUser();
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
    var user = event.user;
    account = await getAccount(user.email);
    isSupervisor = account.supervisor;
    if (PlatformUtils.platform == Constants.mobile || isSupervisor) yield Authenticated(account, isSupervisor);
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _authenticationRepository.signOut();
  }

  /// Function to retrieve from the database the information associated with the
  /// user logged in. The Firebase AuthUser uid must be the same as the id of the
  /// document in the "Utenti" [Constants.tabellaUtenti] collection.
  /// However the mail is also an unique field.
  Future<Account> getAccount(String email) async {
    var query = FirebaseFirestore.instance.collection("Utenti").where('Email', isEqualTo: email);
    var result = await query.get();
    var docs = result.docs;
    for (QueryDocumentSnapshot doc in docs) {
      if (doc != null) {
        return Account.fromMap(doc.id, doc.data());
      }
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
