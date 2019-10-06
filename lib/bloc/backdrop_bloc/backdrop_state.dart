part of 'backdrop_bloc.dart';

@immutable
abstract class BackdropState extends Equatable {
  BackdropState([List props = const []]);
}

class Ready extends BackdropState {
  final String route;
  final dynamic arg;

  Ready([this.route, this.arg]);

  @override
  List<Object> get props => [this.route,this.arg];
}

class NotReady extends BackdropState {
  @override
  List<Object> get props => [];
}








