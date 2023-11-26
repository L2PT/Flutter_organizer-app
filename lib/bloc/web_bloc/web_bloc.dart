import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/views/screens/create_event_view.dart';
import 'package:venturiautospurghi/views/screens/details_event_view.dart';
import 'package:venturiautospurghi/views/screens/operator_selection_view.dart';
import 'package:venturiautospurghi/views/screens/register_view.dart';
import 'package:venturiautospurghi/views/screens/table_calendar_view.dart';

part 'web_event.dart';
part 'web_state.dart';

class WebBloc extends Bloc<WebEvent, WebState> {
  final Account _account;
  List<Widget> overViewStack = [];
  double _posLeftOverView;
  double _posTopOverView;

  WebBloc({
    required CloudFirestoreService databaseRepository,
    required Account account,
    required double posLeftOverView,
    required double posTopOverView
  }) :  _account = account,
        _posLeftOverView = posLeftOverView,
        _posTopOverView = posTopOverView,
       super(NotReady()){
    on<NavigateEvent>(_onNavigateEvent);
    on<InitAppEvent>(_onInitAppEvent);
    // if(Constants.debug)
    //   _databaseRepository.subscribeAccount(account.id).listen((userUpdate){ _account.update(userUpdate);});
  }

  Future<void> _onNavigateEvent(NavigateEvent event, Emitter<WebState> emit) async {
    switch(event.route){
      case Constants.closeOverViewRoute: emit( CloseOverView((event.arg is Map)?event.arg["event"]:Event.empty(),state.route,(event.arg is Map)?event.arg["res"]:false)); break;
      case Constants.detailsEventViewRoute: emit( OverViewReady(event.route, DetailsEvent((event.arg is Event)?event.arg:_getEventFromJson(event.arg)),_posLeftOverView, _posTopOverView, )); break;
      case Constants.createEventViewRoute: emit( OverViewReady(event.route, CreateEvent((event.arg is Map)?event.arg["event"]:event.arg,(event.arg is Map)?event.arg["currentStep"]??0:0, (event.arg is Map)?event.arg["dateSelect"]:DateTime.now()), _posLeftOverView, _posTopOverView,)); break;
      case Constants.monthlyCalendarRoute: emit( OverViewReady(event.route, TableCalendarWithBuilders(), _posLeftOverView, _posTopOverView,)); break;
      case Constants.registerRoute: emit( OverViewReady(event.route, Register(), _posLeftOverView, _posTopOverView,)); break;
      case Constants.operatorListRoute: emit( OverViewReady(event.route, OperatorSelection((event.arg is Map)?event.arg["event"]:event.arg, (event.arg is Map)?event.arg["requirePrimaryOperator"]:false),_posLeftOverView, _posTopOverView)); break;
      case Constants.addWebOperatorRoute: Event e = new Event.empty()..suboperators = _account.webops; e.start = e.end = DateTime(0); emit( OverViewReady(event.route, OperatorSelection(e), _posLeftOverView, _posTopOverView,)); break;
    }
  }

  Event _getEventFromJson(dynamic param){
    Map paramMap = json.decode(param);
    paramMap["DataInizio"] = DateTime.fromMillisecondsSinceEpoch(paramMap["DataInizio"]["seconds"]*1000);
    paramMap["DataFine"] = DateTime.fromMillisecondsSinceEpoch(paramMap["DataFine"]["seconds"]*1000);
    return Event.fromMap(paramMap["id"], paramMap["color"], paramMap);
  }

  /// First method to be called after the login
  /// it initialize the bloc and start the subscription for the notification events
  Future<void> _onInitAppEvent(InitAppEvent event, Emitter<WebState> emit) async {
    print("chiamata iniziale");
    add(NavigateEvent(Constants.homeRoute));
  }

  void updatePositionOverView(DraggableDetails details){
    this._posLeftOverView = details.offset.dx;
    this._posTopOverView = details.offset.dy;
    emit((state as OverViewReady).assign(posLeftOverView: details.offset.dx, posTopOverView: details.offset.dy));
  }

  void underLevelOverView(String route, Widget child){
    emit(OverViewReady(route, child, this._posLeftOverView, this._posTopOverView));
  }
}
