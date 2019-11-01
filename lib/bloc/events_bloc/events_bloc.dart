import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';

part 'events_event.dart';

part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  List<Event> _events = [];
  final EventsRepository _eventsRepository;
  StreamSubscription _eventsSubscription;

  EventsBloc({@required EventsRepository eventsRepository})
      : assert(eventsRepository != null),
        _eventsRepository = eventsRepository;


  @override
  EventsState get initialState => NotLoaded();

  @override
  Stream<EventsState> mapEventToState(EventsEvent event) async* {
    if (event is LoadEvents) {
      yield* _initState(event);
    } else if (event is FilterEventsByDay) {
      yield* _mapLoadEventFilteredByDayToState(event);
    } else if (event is FilterEventsByMonth) {
      yield* _mapLoadEventFilteredByMonthToState(event);
    } else if (event is FilterEventsByWaiting) {
      yield* _mapLoadEventFilteredByWaitingToState(event);
    } else if (event is EventsUpdated) {
      yield* _mapEventsUpdateToState(event);
    } else if (event is Done) {
      yield* _mapDoneToState(event);
    }
  }

  Stream<EventsState> _initState(LoadEvents event) async* {
    //use it as initializer
    //yield NotLoaded(); almost useless
    _eventsSubscription?.cancel();
    //subscribe and do dispatch of interested events
    if(event.subscriptionArgs!=null) {
      _eventsSubscription = event.subscription(event.subscriptionArgs).listen((events) {
            dispatch(
              EventsUpdated(events), //crea l'evento
            );
          });
    }else{
      _eventsSubscription = event.subscription().listen((events) {
            dispatch(
              EventsUpdated(events), //crea l'evento
            );
          });
    }
    //data ready to be fetched
  }

  Stream<EventsState> _mapLoadEventFilteredByDayToState(FilterEventsByDay event) async* {
    //filter the _events end return them
    List<Event> eventsFiltered = List();
    _events.forEach((singleEvent){
      if(singleEvent.isBetweenDate(event.selectedDay, event.selectedDay.add(Duration(days: 1))))
        eventsFiltered.add(singleEvent);
    });
    dispatch(Done(eventsFiltered,event.selectedDay));
  }

  Stream<EventsState> _mapLoadEventFilteredByMonthToState(FilterEventsByMonth event) async* {
    //filter the _events end return them
    List<Event> eventsFiltered = List();
    _events.forEach((singleEvent){
      if(singleEvent.isBetweenDate(event.selectedDay, DateTime(event.selectedDay.year+(event.selectedDay.month+2>12?1:0),event.selectedDay.month+2>12?(event.selectedDay.month+2)-12:event.selectedDay.month+2)))
        eventsFiltered.add(singleEvent);
    });
    dispatch(Done(eventsFiltered,event.selectedDay));
  }

  Stream<EventsState> _mapLoadEventFilteredByWaitingToState(FilterEventsByWaiting event) async* {
    //filter the _events end return them
    _events.sort((a, b) => a.start.compareTo(b.start));
    dispatch(Done(_events,null));
  }

  Stream<EventsState> _mapEventsUpdateToState(EventsUpdated event) async* {
    _events = event.events;
    yield Loaded();
  }

  Stream<EventsState> _mapDoneToState(Done event) async* {
    yield Filtered(event.events, event.selectedDay);  //cambia lo stato
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }


}
