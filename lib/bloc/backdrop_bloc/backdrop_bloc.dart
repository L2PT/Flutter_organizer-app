import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fb_auth/fb_auth.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;

part 'backdrop_event.dart';

part 'backdrop_state.dart';

class BackdropBloc extends Bloc<BackdropEvent, BackdropState> {
  AuthUser user;
  bool isSupervisor;

  BackdropBloc(this.user, this.isSupervisor);

  @override
  BackdropState get initialState => NotReady();

  @override
  Stream<BackdropState> mapEventToState(BackdropEvent event) async* {
    if (event is NavigateEvent) {
      yield* _mapUpdateViewToState(event);
    }
  }

  Stream<BackdropState> _mapUpdateViewToState(NavigateEvent event) async* {
    yield Ready(event.route, event.arg); //cambia lo stato
  }

}
