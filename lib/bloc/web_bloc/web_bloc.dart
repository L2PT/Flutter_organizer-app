import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/view/history_view.dart';

part 'web_event.dart';

part 'web_state.dart';

class WebBloc extends Bloc<WebEvent, WebState> {
  Account user;
  bool isSupervisor;
  final EventsRepository eventsRepository = EventsRepository();
  String route;

  WebBloc(this.user, this.isSupervisor);

  @override
  WebState get initialState => NotReady();

  @override
  Stream<WebState> mapEventToState(WebEvent event) async* {
    if (event is NavigateEvent) {
      yield* _mapUpdateViewToState(event);
    }else if(event is InitAppEvent){
      yield* _mapInitAppToState();
    }
  }

  Stream<WebState> _mapUpdateViewToState(NavigateEvent event) async* {
    dynamic content;
    var subscription;
    var subscriptionArgs;
    int bloctype;
    route = event.route;
    switch(event.route){
      case global.Constants.homeRoute:{
        //nothing to assign
      }break;
      case global.Constants.historyEventListRoute:{
        content = History();
        subscription = eventsRepository.eventsHistory;
        print(subscription);
        bloctype = global.Constants.EVENTS_BLOC;
      }break;
    }
    yield Ready(event.route, content, subscription, subscriptionArgs, bloctype); //cambia lo stato
  }

  /// First method to be called after the login
  /// it initialize the bloc and start the subscription for the notification events
  Stream<WebState> _mapInitAppToState() async* {
    await eventsRepository.init();
    add(NavigateEvent(global.Constants.homeRoute,null));
  }
}
