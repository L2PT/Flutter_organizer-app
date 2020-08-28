part of 'waiting_event_list_cubit.dart';

abstract class WaitingEventListState extends Equatable {
  WaitingEventListState([List props = const []]);
}

class LoadingEvents extends WaitingEventListState {
  @override
  List<Object> get props => [];
}

class ReadyEvents extends WaitingEventListState {
  List<Event> events;

  ReadyEvents(this.events);

  @override
  List<Object> get props => [events];
}