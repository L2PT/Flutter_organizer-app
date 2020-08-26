import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/auth/authuser.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/views/screen_pages/daily_calendar_view.dart';
import 'package:venturiautospurghi/views/screens/details_event_view.dart';
import 'package:venturiautospurghi/views/screens/create_event_view.dart';
import 'package:venturiautospurghi/views/screen_pages/history_view.dart';
import 'package:venturiautospurghi/views/screen_pages/monthly_calendar_view.dart';
import 'package:venturiautospurghi/views/screen_pages/operator_list_view.dart';
import 'package:venturiautospurghi/views/screens/register_view.dart';
import 'package:venturiautospurghi/views/screen_pages/waiting_event_view.dart';

part 'mobile_event.dart';

part 'mobile_state.dart';
///
/// The bloc that handle all the navigation and the global state for the mobile part of the application
///
/// START
/// starts in the state [NotReady] -> the view shows the splashscreen
/// the view trigger the [InitAppEvent] that trigger the [NavigateEvent] to home that change the state
///
class MobileBloc extends Bloc<MobileEvent, MobileState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  StreamSubscription<AuthUser> _notificationSubscription;
  String actualRoute;

  MobileBloc({
    @required CloudFirestoreService databaseRepository,
    @required Account account
  })  : assert(databaseRepository != null && account != null),
        _databaseRepository = databaseRepository,
        _account = account,
        super(NotReady()) {
    _notificationSubscription = _databaseRepository.onNewNotificationIncoming.listen(
          //TODO check if the add below works or you had to trigger every time the [NotificationWaitingState]
          (notification) {
            if(this.state is NotificationWaitingState) (this.state as NotificationWaitingState).events.add(notification);
            else add(NotificationWaitingState(List<Event>.of(notification)));

          }
    );

    //TODO other standard stuff
  }

  @override
  Stream<MobileState> mapEventToState(MobileEvent event) async* {
    if (event is NavigateEvent) {
      yield* _mapUpdateViewToState(event);
    }
    if(event is InitAppEvent) {
      yield* _mapInitAppToState(event);
    }
  }

  ///Update the view, the logic is here!!! not in the view

  Stream<MobileState> _mapUpdateViewToState(NavigateEvent event) async* {
    dynamic content;
    var subscription;
    var subscriptionArgs;
    int bloctype;
    actualRoute = event.route;
    switch(event.route) {
      case Constants.detailsEventViewRoute: yield OutBackdropState(event.route, DetailsEvent(event.arg)); break;
      case Constants.createEventViewRoute: yield OutBackdropState(event.route, CreateEvent(event.args)); break;
      case Constants.registerRoute: yield OutBackdropState(event.route, Register()); break;
      case Constants.homeRoute: {
        if(_account.supervisor) {
          content = OperatorList();
          subscription = eventsRepository.subscribeEvents;
          bloctype = Constants.OPERATORS_BLOC;
        }else{
          content = DailyCalendar(null);
          subscription = eventsRepository.eventsByOperatorAcceptedOrAbove;
          subscriptionArgs = user.id;
          bloctype = Constants.EVENTS_BLOC;
        }
      } break;
      case Constants.monthlyCalendarRoute: {
        content = MonthlyCalendar(event.arg);
        if(operator != null || !isSupervisor){
          subscription = eventsRepository.eventsByOperator;
          subscriptionArgs = !isSupervisor?user.id:operator.id;
        }else
          subscription = eventsRepository.subscribeEvents;
        bloctype = Constants.EVENTS_BLOC;
      } break;
      case Constants.dailyCalendarRoute: {
        //arg 1: operator
        //arg 2: day
        if(event.arg!=null && event.arg[0]!=null)
          operator = event.arg[0];
        if(event.arg!=null && event.arg[1]!=null)
          day = event.arg[1];
        else
          day=TimeUtils.truncateDate(DateTime.now(),"day");
        content = DailyCalendar(event.arg[1]);
        if(isSupervisor)
          subscription = eventsRepository.eventsByOperator;
        else
          subscription = eventsRepository.eventsByOperatorAcceptedOrAbove;
        subscriptionArgs = !isSupervisor?user.id:operator.id;
        bloctype = Constants.EVENTS_BLOC;
      } break;
      case Constants.profileRoute: {
        //content = Profile;
      }
      break;
      case Constants.registerRoute: {
        bloctype = Constants.OUT_OF_BLOC;
        content = Register();
      }
      break;
      case Constants.operatorListRoute: {
        content = OperatorList();
        subscription = eventsRepository.subscribeEvents;
        bloctype = Constants.OPERATORS_BLOC;
      }
      break;
      case Constants.createEventViewRoute: {
        bloctype = Constants.OUT_OF_BLOC;
        content = CreateEvent(null);
      }
      break;
      case Constants.waitingEventListRoute: {
        //pay attention this works only for Operators
        content = waitingEvent();
        subscription = eventsRepository.eventsWaiting;
        subscriptionArgs = user.id;
        bloctype = Constants.EVENTS_BLOC;
      }
      break;
      case Constants.historyEventListRoute: {
        //pay attention this works only for Operators
        content = History();
        subscription = eventsRepository.eventsHistory;
        bloctype = Constants.EVENTS_BLOC;
      }
      break;
      default: {content = DailyCalendar(null);}
      break;
    }
    yield Ready(event.route, content, subscription, subscriptionArgs, bloctype); //cambia lo stato

  }

  /// First method to be called after the login
  /// it initialize the bloc and start the subscription for the notification events
  Stream<MobileState> _mapInitAppToState(InitAppEvent event) async* {
    //TODO is it really necessary? maybe
    //await eventsRepository.init();
    add(NavigateEvent(Constants.homeRoute,null));
  }

}