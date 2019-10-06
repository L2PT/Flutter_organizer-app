part of 'events_bloc.dart';

@immutable
abstract class EventsState extends Equatable {
  EventsState([List props = const []]);
}

class Loaded extends EventsState {
  final List<Event> events;
  final DateTime selectedDay;

  Loaded([this.events, this.selectedDay]);

  @override
  List<Object> get props => [events, selectedDay];
}

//class Loaded extends EventsState {
//  @override
//  List<Object> get props => [];
//}

class NotLoaded extends EventsState {
  @override
  List<Object> get props => [];
}








