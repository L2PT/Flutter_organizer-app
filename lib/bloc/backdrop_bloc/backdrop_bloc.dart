import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/view/daily_calendar_view.dart';
import 'package:venturiautospurghi/view/form_event_creator_view.dart';
import 'package:venturiautospurghi/view/history_view.dart';
import 'package:venturiautospurghi/view/monthly_calendar_view.dart';
import 'package:venturiautospurghi/view/operator_list_view.dart';
import 'package:venturiautospurghi/view/register_view.dart';
import 'package:venturiautospurghi/view/waiting_event_view.dart';

part 'backdrop_event.dart';

part 'backdrop_state.dart';

class BackdropBloc extends Bloc<BackdropEvent, BackdropState> {
  Account user;
  bool isSupervisor;
  final EventsRepository eventsRepository = EventsRepository();
  Account operator;
  DateTime day;
  String route;

  BackdropBloc(this.user, this.isSupervisor);

  @override
  BackdropState get initialState => NotReady();

  @override
  Stream<BackdropState> mapEventToState(BackdropEvent event) async* {
    if (event is NavigateEvent) {
      yield* _mapUpdateViewToState(event);
    }
    if(event is InitAppEvent) {
      yield* _mapInitAppToState(event);
    }
    if(event is CreateNotificationEvent) {
      yield* _mapCreateNoficationEvent(event);
    }
  }


  /// All incoming events of navigation mapped to state ready filling properly
  /// the content: with the page to be visualized in the front layer of the backdrop class
  /// the subscription: the snapshot STILL TO BE EXECUTED to retrieve the data for the choosen page
  ///   *Input* an event with the rout and the argument for that route
  ///           NOTE: the argument for the navigation from the backdrop menu is null as default
  ///   *Output* a state Ready with the content, the subscription and the argument to execute
  ///           the subscription with and the subtype that choose the bloc to submit the event
  ///           in the backdrop
  ///

  Stream<BackdropState> _mapUpdateViewToState(NavigateEvent event) async* {
    dynamic content;
    var subscription;
    var subscriptionArgs;
    int bloctype;
    route = event.route;
    switch(event.route) {
      case global.Constants.homeRoute: {
        if(isSupervisor) {
          content = OperatorList();
          subscription = eventsRepository.events;
          bloctype = global.Constants.OPERATORS_BLOC;
        }else{
          content = DailyCalendar(null);
          subscription = eventsRepository.eventsByOperatorAcceptedOrAbove;
          subscriptionArgs = user.id;
          bloctype = global.Constants.EVENTS_BLOC;
        }
      }
      break;
      case global.Constants.monthlyCalendarRoute: {
        content = MonthlyCalendar(event.arg);
        if(operator != null || !isSupervisor){
          subscription = eventsRepository.eventsByOperator;
          subscriptionArgs = !isSupervisor?user.id:operator.id;
        }else
          subscription = eventsRepository.events;
        bloctype = global.Constants.EVENTS_BLOC;
      }
      break;
      case global.Constants.dailyCalendarRoute: {
        //arg 1: operator
        //arg 2: day
        if(event.arg!=null && event.arg[0]!=null)
          operator = event.arg[0];
        if(event.arg!=null && event.arg[1]!=null)
          day = event.arg[1];
        else
          day=Utils.formatDate(DateTime.now(),"day");
        content = DailyCalendar(event.arg[1]);
        if(isSupervisor)
          subscription = eventsRepository.eventsByOperator;
        else
          subscription = eventsRepository.eventsByOperatorAcceptedOrAbove;
        subscriptionArgs = !isSupervisor?user.id:operator.id;
        bloctype = global.Constants.EVENTS_BLOC;
      }
      break;
      case global.Constants.profileRoute: {
        //content = Profile;
      }
      break;
      case global.Constants.registerRoute: {
        bloctype = global.Constants.OUT_OF_BLOC;
        content = Register();
      }
      break;
      case global.Constants.operatorListRoute: {
        content = OperatorList();
        subscription = eventsRepository.events;
        bloctype = global.Constants.OPERATORS_BLOC;
      }
      break;
      case global.Constants.formEventCreatorRoute: {
        bloctype = global.Constants.OUT_OF_BLOC;
        content = EventCreator(null);
      }
      break;
      case global.Constants.waitingEventListRoute: {
        //pay attention this works only for Operators
        content = waitingEvent();
        subscription = eventsRepository.eventsWaiting;
        subscriptionArgs = user.id;
        bloctype = global.Constants.EVENTS_BLOC;
      }
      break;
      case global.Constants.historyEventListRoute: {
        //pay attention this works only for Operators
        content = History();
        subscription = eventsRepository.eventsHistory;
        bloctype = global.Constants.EVENTS_BLOC;
      }
      break;
      default: {content = DailyCalendar(null);}
      break;
    }
    yield Ready(event.route, content, subscription, subscriptionArgs, bloctype); //cambia lo stato

  }

  /// First method to be called after the login
  /// it initialize the bloc and start the subscription for the notification events
  Stream<BackdropState> _mapInitAppToState(InitAppEvent event) async* {
    await eventsRepository.init();
    add(NavigateEvent(global.Constants.homeRoute,null));
    eventsRepository.eventsWaiting(user.id).listen((events) {
      if(events.length>0 && route!=global.Constants.waitingEventListRoute){
        add(
              CreateNotificationEvent(events)
          );
      }else if(events.length==0){
        if(this.state is NotificationWaitingState) add(NavigateEvent(global.Constants.homeRoute,null));
      }
    }
    );
  }

  /// Function that force the backdrop to switch state to show the user the
  /// notifications on top of the screen
  Stream<BackdropState> _mapCreateNoficationEvent(CreateNotificationEvent event) async* {
    yield NotificationWaitingState(event.waitingEvents);
  }

}