part of 'backdrop_bloc.dart';

@immutable
abstract class BackdropState extends Equatable {
  BackdropState([List props = const []]);
}

class Ready extends BackdropState {
  final String route;
  final dynamic content;
  final dynamic subscription;
  final dynamic subscriptionArgs;
  final int subtype;

  Ready([this.route, this.content, this.subscription, this.subtype, this.subscriptionArgs]) : super([route,content,subscription,subscriptionArgs,subtype]);

  @override
  List<Object> get props => [route,content,subscription,subscriptionArgs,subtype];
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








