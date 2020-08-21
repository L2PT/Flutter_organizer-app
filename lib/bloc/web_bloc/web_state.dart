//part of 'web_bloc.dart';
//
//@immutable
//abstract class WebState extends Equatable {
//  WebState([List props = const []]);
//}
//
//class Ready extends WebState {
//  final String route;
//  final dynamic content;
//  final dynamic subscription;
//  final dynamic subscriptionArgs;
//  final int subtype;
//
//  Ready([this.route, this.content, this.subscription, this.subscriptionArgs, this.subtype]) : super([route,content,subscription,subscriptionArgs,subtype]);
//
//  @override
//  List<Object> get props => [route,content,subscription,subscriptionArgs,subtype];
//}
//
//class NotReady extends WebState {
//  @override
//  List<Object> get props => [];
//}