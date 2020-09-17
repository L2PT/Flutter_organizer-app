import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/views/screen_pages/history_view.dart';
import 'package:venturiautospurghi/views/screen_pages/operator_list_view.dart';
import 'package:venturiautospurghi/views/screen_pages/operator_selection_view.dart';
import 'package:venturiautospurghi/views/screens/create_event_view.dart';
import 'package:venturiautospurghi/views/screens/details_event_view.dart';
import 'package:venturiautospurghi/views/screens/register_view.dart';
import 'package:venturiautospurghi/views/screens/table_calendar_view.dart';

part 'web_event.dart';

part 'web_state.dart';

class WebBloc extends Bloc<WebEvent, WebState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  String actualRoute;
  List<BuildContext> dialogStack = [];

  WebBloc({
    @required CloudFirestoreService databaseRepository,
    @required Account account
  })  : assert(databaseRepository != null && account != null),
        _databaseRepository = databaseRepository,
        _account = account,
        super(NotReady()){
    if(Constants.debug) _databaseRepository.subscribeAccount(account.id).listen((userUpdate){ account.update(userUpdate);});

  }


  @override
  Stream<WebState> mapEventToState(WebEvent event) async* {
    if (event is NavigateEvent) {
      yield* _mapUpdateViewToState(event);
    }else if(event is InitAppEvent){
      yield* _mapInitAppToState();
    }
  }

  Stream<WebState> _mapUpdateViewToState(NavigateEvent event) async* {
    switch(event.route){
      case Constants.homeRoute: yield Ready(event.route, null); break;
      case Constants.historyEventListRoute: yield Ready(event.route, OperatorList()); break;
      case Constants.detailsEventViewRoute: yield DialogReady(event.route, DetailsEvent((event.arg is Event)?event.arg:_getEventFromJson(event.arg)), event.callerContext); break;
      case Constants.createEventViewRoute: yield DialogReady(event.route, CreateEvent(event.arg), event.callerContext); break;
      case Constants.monthlyCalendarRoute: yield DialogReady(event.route, TableCalendarWithBuilders(), event.callerContext); break;
      case Constants.registerRoute: yield DialogReady(event.route, Register(), event.callerContext); break;
      case Constants.operatorListRoute:  yield DialogReady(event.route, OperatorSelection((event.arg is List)?event.arg[0]:event.arg, (event.arg is List)?event.arg[1]:false), event.callerContext); break;
      case Constants.addWebOperatorRoute: Event e = new Event.empty()..suboperators = _account.webops; yield DialogReady(event.route, OperatorSelection(e), event.callerContext); break;
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
  Stream<WebState> _mapInitAppToState() async* {
    add(NavigateEvent(Constants.homeRoute));
  }
}
