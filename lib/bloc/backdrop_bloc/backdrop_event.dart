part of 'backdrop_bloc.dart';

@immutable
abstract class BackdropEvent extends Equatable {
  BackdropEvent([List props = const []]);
}

class NavigateEvent extends BackdropEvent {
  final String route;
  final dynamic arg;

  NavigateEvent(this.route, this.arg) : super([route,arg]);

  @override
  List<Object> get props => [route,arg];
}

class InitAppEvent extends BackdropEvent {
  @override
  List<Object> get props => [];
}

class CreateNotificationEvent extends BackdropEvent {
  final List<Event> waitingEvent;

  CreateNotificationEvent(this.waitingEvent) : super(waitingEvent);

  @override
  List<Object> get props => [waitingEvent];
}
