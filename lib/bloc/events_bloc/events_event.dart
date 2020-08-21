//part of 'events_bloc.dart';
//
//@immutable
//abstract class EventsEvent extends Equatable {
//  EventsEvent([List props = const []]);
//}
//
//class LoadEvents extends EventsEvent {
//  final dynamic subscription;
//  final dynamic subscriptionArgs;
//
//  LoadEvents(this.subscription, this.subscriptionArgs) : super([subscription,subscriptionArgs]);
//
//  @override
//  List<Object> get props => [subscription,subscriptionArgs];
//}
//
//class FilterEventsByDay extends EventsEvent {
//  final DateTime selectedDay;
//
//  FilterEventsByDay(this.selectedDay) : super([selectedDay]);
//
//  @override
//  List<Object> get props => [selectedDay];
//}
//
//class FilterEventsByMonth extends EventsEvent {
//  final DateTime selectedDay;
//
//  FilterEventsByMonth(this.selectedDay) : super([selectedDay]);
//
//  @override
//  List<Object> get props => [selectedDay];
//}
//
//class FilterEventsByWaiting extends EventsEvent {
//  @override
//  List<Object> get props => [];
//}
//
//class FilterEventsByStatus extends EventsEvent {
//  final int selectedStatus;
//
//  FilterEventsByStatus(this.selectedStatus) : super([selectedStatus]);
//
//  @override
//  List<Object> get props => [selectedStatus];
//}
//
//class EventsUpdated extends EventsEvent {
//  final List<Event> events;
//
//  EventsUpdated(this.events);
//
//  @override
//  List<Object> get props => [events];
//}
//
//class Done extends EventsEvent {
//  final List<Event> events;
//  final DateTime selectedDay;
//
//  Done(this.events, this.selectedDay);
//
//  @override
//  List<Object> get props => [events,selectedDay];
//}