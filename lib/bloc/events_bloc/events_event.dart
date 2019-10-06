part of 'events_bloc.dart';

@immutable
abstract class EventsEvent extends Equatable {
  EventsEvent([List props = const []]);
}

class LoadEventsOnce extends EventsEvent {
  final DateTime selectedDay;

  LoadEventsOnce(this.selectedDay) : super([selectedDay]);

  @override
  List<Object> get props => [selectedDay];
}

class LoadEvents extends EventsEvent {
  final DateTime selectedDay;

  LoadEvents(this.selectedDay) : super([selectedDay]);

  @override
  List<Object> get props => [selectedDay];
}

class AddEvent extends EventsEvent {
  final Event event;

  AddEvent(this.event) : super([event]);

  @override
  List<Object> get props => [event];
}

class UpdateEvent extends EventsEvent {
  final Event event;

  UpdateEvent(this.event) : super([event]);

  @override
  List<Object> get props => [event];
}

class DeleteEvent extends EventsEvent {
  final Event event;

  DeleteEvent(this.event) : super([event]);

  @override
  List<Object> get props => [event];
}

class EventsUpdated extends EventsEvent {
  final List<Event> events;
  final DateTime selectedDay;

  EventsUpdated(this.events, this.selectedDay);

  @override
  List<Object> get props => [events, selectedDay];
}

class Done extends EventsEvent {
  @override
  List<Object> get props => [];
}