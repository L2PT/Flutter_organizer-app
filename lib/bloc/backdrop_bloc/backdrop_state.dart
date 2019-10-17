part of 'backdrop_bloc.dart';

@immutable
abstract class BackdropState extends Equatable {
  BackdropState([List props = const []]);
}

class Ready extends BackdropState {
  final String route;
  final dynamic content;
  final dynamic subscription;

  Ready([this.route, this.content, this.subscription]) : super([route,content,subscription]);

  @override
  List<Object> get props => [route,content,subscription];
}

class NotReady extends BackdropState {
  @override
  List<Object> get props => [];
}

class NotificationWatingEvent extends BackdropState {
  final List<Event> watingEvent;

  NotificationWatingEvent(this.watingEvent) : super(watingEvent);

  @override
  List<Object> get props => [watingEvent];
}








