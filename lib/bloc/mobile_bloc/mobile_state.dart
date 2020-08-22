part of 'mobile_bloc.dart';

@immutable
abstract class MobileState extends Equatable {
  MobileState([List props = const []]);
}

class InBackdropState extends MobileState {
  final String route;
  final dynamic content;
  final dynamic subscription;
  final dynamic subscriptionArgs;
  final int subtype;

  InBackdropState([this.route, this.content, this.subscription, this.subscriptionArgs, this.subtype]) : super([route,content,subscription,subscriptionArgs,subtype]);

  @override
  List<Object> get props => [route,content,subscription,subscriptionArgs,subtype];
}

class OutBackdropState extends MobileState {
  final String route;
  final dynamic content;

  OutBackdropState([this.route, this.content]) : super([route,content]);

  @override
  List<Object> get props => [route,content];
}

class NotReady extends MobileState {
  @override
  List<Object> get props => [];
}

class NotificationWaitingState extends MobileState {
  final List<Event> events;

  NotificationWaitingState(this.events) : super(events);

  @override
  List<Object> get props => [events];
}








