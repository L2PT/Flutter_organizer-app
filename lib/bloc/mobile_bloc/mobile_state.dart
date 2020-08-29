part of 'mobile_bloc.dart';

@immutable
abstract class MobileState extends Equatable {
  final String route;
  final dynamic content;

  MobileState(this.route, this.content);

  @override
  List<Object> get props => [route,content];
}

class InBackdropState extends MobileState {

  InBackdropState(String route, content) : super(route, content);

}

class OutBackdropState extends MobileState {

  OutBackdropState(String route, content) : super(route, content);

}

class NotReady extends MobileState {
  NotReady() : super(null, null);
}

class NotificationWaitingState extends MobileState {

  NotificationWaitingState(String route, content) : super(route, content);

}








