import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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

  WebBloc({
    @required CloudFirestoreService databaseRepository,
    @required Account account
  })  : assert(databaseRepository != null && account != null),
        _databaseRepository = databaseRepository,
        _account = account,
        super(NotReady());

  @override
  Stream<WebState> mapEventToState(WebEvent event) async* {
    if (event is NavigateEvent) {
      yield* _mapUpdateViewToState(event);
    }else if(event is InitAppEvent){
      yield* _mapInitAppToState();
    }
  }

  Stream<WebState> _mapUpdateViewToState(NavigateEvent event) async* {
    print("here "+event.route);
    switch(event.route){
      case Constants.homeRoute: yield Ready(event.route, null); break;
      case Constants.historyEventListRoute: yield Ready(event.route, OperatorList()); break;
      case Constants.detailsEventViewRoute: yield DialogReady(event.route, DetailsEvent((state.content is Event)?state.content:_getEventFromJson(state.content))); break;
      case Constants.createEventViewRoute: yield DialogReady(event.route, CreateEvent(state.content)); break;
      case Constants.monthlyCalendarRoute: yield DialogReady(event.route, TableCalendarWithBuilders()); break;
      case Constants.registerRoute: yield DialogReady(event.route, Register()); break;
      case Constants.operatorListRoute:  yield DialogReady(event.route, OperatorSelection());
    }
  }

  Event _getEventFromJson(dynamic param){
    Map paramMap = json.decode(param);
    return PlatformUtils.EventFromMap(paramMap["id"], paramMap["color"], paramMap);
  }

  /// First method to be called after the login
  /// it initialize the bloc and start the subscription for the notification events
  Stream<WebState> _mapInitAppToState() async* {
    add(NavigateEvent(Constants.homeRoute,null));
  }
}
