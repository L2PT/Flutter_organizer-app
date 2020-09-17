part of 'web_bloc.dart';

@immutable
abstract class WebEvent extends Equatable {
  WebEvent([List props = const []]);
}

class NavigateEvent extends WebEvent {
  final String route;
  dynamic arg;
  BuildContext callerContext;

  NavigateEvent(this.route, [this.arg, this.callerContext]) : super([route,arg]);

  @override
  List<Object> get props => [route,arg];
}

class InitAppEvent extends WebEvent {
  @override
  List<Object> get props => [];
}