part of 'mobile_bloc.dart';

@immutable
abstract class MobileEvent extends Equatable {
  MobileEvent([List props = const []]);
}

class NavigateEvent extends MobileEvent {
  final String route;
  final dynamic arg;

  NavigateEvent(this.route, [this.arg]) : super([route,arg]);

  @override
  List<Object> get props => [route,arg];
}

class InitAppEvent extends MobileEvent {
  @override
  List<Object> get props => [];
}