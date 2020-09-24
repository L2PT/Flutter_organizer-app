import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/auth/authuser.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/views/screen_pages/daily_calendar_view.dart';
import 'package:venturiautospurghi/views/screen_pages/user_profile_view.dart';
import 'package:venturiautospurghi/views/screens/details_event_view.dart';
import 'package:venturiautospurghi/views/screens/create_event_view.dart';
import 'package:venturiautospurghi/views/screen_pages/history_view.dart';
import 'package:venturiautospurghi/views/screen_pages/monthly_calendar_view.dart';
import 'package:venturiautospurghi/views/screen_pages/operator_list_view.dart';
import 'package:venturiautospurghi/views/screens/persistent_notification_view.dart';
import 'package:venturiautospurghi/views/screens/register_view.dart';
import 'package:venturiautospurghi/views/screen_pages/waiting_event_list_view.dart';

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
  StreamSubscription<List<Event>> _notificationSubscription;
  String actualRoute;
  List<Event> notification;

  MobileBloc({
    @required CloudFirestoreService databaseRepository,
    @required Account account
  })  : assert(databaseRepository != null && account != null),
        _databaseRepository = databaseRepository,
        _account = account,
        super(NotReady());

  @override
  Stream<MobileState> mapEventToState(MobileEvent event) async* {
    if (event is NavigateEvent) {
      yield* _mapUpdateViewToState(event);
    }else if(event is InitAppEvent) {
      yield* _mapInitAppToState(event);
    }
  }

  ///Map for the navigation event to update the view
  Stream<MobileState> _mapUpdateViewToState(NavigateEvent event) async* {
    if(this.state is NotificationWaitingState) {
      if(event.route != Constants.waitingNotificationRoute && event.route != Constants.waitingEventListRoute){
        event.route = Constants.waitingNotificationRoute;
      }
    }

    switch(event.route) {
      /*TODO i guess ouofbloc must not match a change of state but a push like so (test as is with fab daily +)
          Navigator.pushNamed(context, Constants.createEventViewRoute, arguments: ev);*/
      case Constants.detailsEventViewRoute: yield OutBackdropState(event.route, DetailsEvent(event.arg)); break;
      case Constants.createEventViewRoute: yield OutBackdropState(event.route, CreateEvent(event.arg)); break;
      case Constants.registerRoute: yield OutBackdropState(event.route, Register()); break;
      case Constants.waitingNotificationRoute: yield NotificationWaitingState(event.route, PersistentNotification(notification)); break;
      case Constants.homeRoute: yield InBackdropState(event.route, _account.supervisor? OperatorList() : DailyCalendar(event.arg != null? event.arg['day']:null,event.arg != null?event.arg['operator']:null) ); break;
      case Constants.monthlyCalendarRoute: yield InBackdropState(event.route, MonthlyCalendar(event.arg != null?event.arg['month']:null,event.arg != null?event.arg['operator']:null) ); break;
      case Constants.dailyCalendarRoute: yield InBackdropState(event.route, DailyCalendar(event.arg['day'],event.arg['operator']) ); break;
      case Constants.profileRoute: yield InBackdropState(event.route, Profile()); break;
      case Constants.operatorListRoute: yield InBackdropState(event.route, OperatorList()); break;
      case Constants.createEventViewRoute: yield InBackdropState(event.route, CreateEvent()); break;
      case Constants.waitingEventListRoute: yield InBackdropState(event.route, WaitingEventList()); break;
      case Constants.historyEventListRoute:  yield InBackdropState(event.route, Profile()); break;
      default: yield InBackdropState(event.route, Profile()); break;
      break;
    }
  }

  /// First method to be called after the login
  /// it initialize the bloc and start the subscription for the notification events
  Stream<MobileState> _mapInitAppToState(InitAppEvent event) async* {
    //add(NavigateEvent(Constants.homeRoute,null)); //TODO this command order is right?
   if (!_account.supervisor) {
      _notificationSubscription = _databaseRepository.subscribeEventsByOperatorWaiting(_account.id).listen((notifications)  {
        if (notifications.length > 0 && !(this.state is NotificationWaitingState)) {
          notification = notifications;
          add(NavigateEvent(Constants.waitingNotificationRoute));
        }
        else if (notifications.length == 0 && (this.state is NotificationWaitingState)) add(NavigateEvent(Constants.homeRoute));
      });
    }
  }
}