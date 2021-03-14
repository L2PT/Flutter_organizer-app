part of 'waiting_event_list_cubit.dart';

abstract class WaitingEventListState extends Equatable {
  WaitingEventListState();

  @override
  List<Object> get props => [];
}

class LoadingEvents extends WaitingEventListState {

}

class ReadyEvents extends WaitingEventListState {
  final List<Event> events;

  ReadyEvents(this.events);

  @override
  List<Object> get props => [events];
}