part of 'mobile_bloc.dart';

@immutable
abstract class MobileEvent extends Equatable {
  MobileEvent([List props = const []]);
}

class NavigateEvent extends MobileEvent {
  String route;
  dynamic arg;

  NavigateEvent(this.route, [this.arg]) : super();

  @override
  List<Object> get props => [route,arg];
}

class NavigateBackEvent extends MobileEvent {
  @override
  List<Object> get props => [];
}

class InitAppEvent extends MobileEvent {
  @override
  List<Object> get props => [];
}