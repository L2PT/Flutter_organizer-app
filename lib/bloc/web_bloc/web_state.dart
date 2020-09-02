part of 'web_bloc.dart';

@immutable
abstract class WebState extends Equatable {
  final String route;
  final dynamic content;

  WebState(this.route, this.content);

  @override
  List<Object> get props => [route,content];
}

class Ready extends WebState {

  Ready(String route, content) : super(route, content);

}

class DialogReady extends WebState {

  DialogReady(String route, content) : super(route, content);

}

class NotReady extends WebState {
  NotReady() : super(null, null);
}