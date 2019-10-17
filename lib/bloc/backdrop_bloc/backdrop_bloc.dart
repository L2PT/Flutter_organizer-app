import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fb_auth/fb_auth.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/bloc/events_bloc/events_bloc.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/view/daily_calendar_view.dart';
import 'package:venturiautospurghi/view/details_event_view.dart';
import 'package:venturiautospurghi/view/form_event_creator_view.dart';
import 'package:venturiautospurghi/view/monthly_calendar_view.dart';
import 'package:venturiautospurghi/view/operator_list_view.dart';
import 'package:venturiautospurghi/view/user_profile_view.dart';
import 'package:venturiautospurghi/view/waiting_event_view.dart';

part 'backdrop_event.dart';

part 'backdrop_state.dart';

class BackdropBloc extends Bloc<BackdropEvent, BackdropState> {
  AuthUser user;
  bool isSupervisor;
  final EventsRepository eventsRepository = EventsRepository();

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
    if(event is CreateNoficationEvent) {
      yield* _mapCreateNoficationEvent(event);
    }

  }

  Stream<BackdropState> _mapUpdateViewToState(NavigateEvent event) async* {
    dynamic content;
    var subscription;
    switch(event.route) {
      case global.Constants.homeRoute: {
        if(isSupervisor) content = OperatorList();
        else{
          content = DailyCalendar(null);
          subscription = eventsRepository.events;
        }};
      break;
      case global.Constants.monthlyCalendarRoute: {
        content = MonthlyCalendar(event.arg);
        subscription = eventsRepository.events;
      }
      break;
      case global.Constants.dailyCalendarRoute: {
        content = DailyCalendar(event.arg);
        subscription = eventsRepository.events;
      }
      break;
      case global.Constants.profileRoute: {
        content = Profile;
      }
      break;
      case global.Constants.operatorListRoute: {
        content = OperatorList;
      }
      break;
      case global.Constants.detailsEventViewRoute: {
        content = DetailsEvent(event.arg);
      }
      break;
      case global.Constants.formEventCreatorRoute: {
        content = EventCreator;
      }
      break;
      case global.Constants.waitingEventListRoute: {
        content = waitingEvent();
        //choose the query
        subscription = eventsRepository.events;
      }
      break;
      default: {content = DailyCalendar(null);}
      break;
    }
    yield Ready(event.route, content, subscription); //cambia lo stato

  }

  Stream<BackdropState> _mapInitAppToState(InitAppEvent event) async* {
    eventsRepository.eventsWating().listen((events) =>
        CreateNoficationEvent(events)
    );
    dispatch(NavigateEvent(global.Constants.homeRoute,null));
  }

  Stream<BackdropState> _mapCreateNoficationEvent(CreateNoficationEvent event) async* {
    yield NotificationWatingEvent(event.watingEvent);
  }
}