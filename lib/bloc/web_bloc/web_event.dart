part of 'web_bloc.dart';

@immutable
abstract class WebEvent extends Equatable {
  WebEvent();
  
  @override
  List<Object> get props => [];
  
}

class NavigateEvent extends WebEvent {
  final String route;
  dynamic arg;
  BuildContext? callerContext;

  NavigateEvent(this.route, [this.arg, this.callerContext]) : super();

  @override
  List<Object> get props => [route,arg];
}

class InitAppEvent extends WebEvent {
  
}