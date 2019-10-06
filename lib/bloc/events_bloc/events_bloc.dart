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
  final EventsRepository _eventsRepository;
  StreamSubscription _eventsSubscription;

  EventsBloc({@required EventsRepository eventsRepository})
      : assert(eventsRepository != null),
        _eventsRepository = eventsRepository;

  @override
  EventsState get initialState => NotLoaded();

  @override
  Stream<EventsState> mapEventToState(EventsEvent event) async* {
    if (event is LoadEventsOnce) {
      yield* _mapLoadEventOnceToState(event);
    } else if (event is LoadEvents) {
      yield* _mapLoadEventToState();
    } else if (event is AddEvent) {
      yield* _mapAddEventToState(event);
    } else if (event is UpdateEvent) {
      yield* _mapUpdateEventToState(event);
    } else if (event is DeleteEvent) {
      yield* _mapDeleteEventToState(event);
    } else if (event is EventsUpdated) {
      yield* _mapEventsUpdateToState(event);
    } else if (event is Done) {
      yield* _mapDoneToState();
    }
  }

  Stream<EventsState> _mapLoadEventOnceToState(LoadEventsOnce event) async* {
    _eventsRepository.getEvents(event.selectedDay).then((events){
        dispatch(EventsUpdated(events,event.selectedDay));
      }
    );
  }

  Stream<EventsState> _mapLoadEventToState() async* {
    _eventsSubscription?.cancel();
    _eventsSubscription = _eventsRepository.events().listen((events) {
        dispatch(
          EventsUpdated(events,null), //crea l'evento
        );
      },
    );
  }

  Stream<EventsState> _mapAddEventToState(AddEvent event) async* {
    _eventsRepository.addNewEvent(event.event);
  }

  Stream<EventsState> _mapUpdateEventToState(UpdateEvent event) async* {
    _eventsRepository.updateEvent(event.event);
  }

  Stream<EventsState> _mapDeleteEventToState(DeleteEvent event) async* {
    _eventsRepository.deleteEvent(event.event);
  }

  Stream<EventsState> _mapEventsUpdateToState(EventsUpdated event) async* {
    yield Loaded(event.events, event.selectedDay); //cambia lo stato
  }

  Stream<EventsState> _mapDoneToState() async* {
    yield Loaded();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

}
