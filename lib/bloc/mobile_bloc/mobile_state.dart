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
  final bool isRestoring;

  InBackdropState(String route, content, {this.isRestoring = false}) : super(route, content);

  InBackdropState restore() => InBackdropState(this.route, this.content, isRestoring: true);

  @override
  List<Object> get props => [route, content, isRestoring, this.runtimeType];

}

class OutBackdropState extends MobileState {
  final bool isLeaving;

  OutBackdropState(String route, content, {this.isLeaving = false}) : super(route, content);

  OutBackdropState leave() => OutBackdropState(this.route, this.content, isLeaving: true);

  @override
  List<Object> get props => [route, content, isLeaving, this.runtimeType];
}

class NotReady extends MobileState {
  NotReady() : super("", null);
}

class NotificationWaitingState extends MobileState {

  NotificationWaitingState(route, content) : super(route, content);

  @override
  List<Object> get props => [route, content, this.runtimeType];
}







