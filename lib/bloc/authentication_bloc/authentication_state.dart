part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState extends Equatable {
  AuthenticationState([List props = const []]);
}

class Uninitialized extends AuthenticationState {
  @override
  List<Object> get props => [];
}

class Authenticated extends AuthenticationState {
  final Account user;
  final bool isSupervisor;
  final List<dynamic> token;

  Authenticated([this.user,this.isSupervisor, this.token]) : super([user,isSupervisor,token]);

  @override
  List<Object> get props => [this.user,this.isSupervisor,this.token];
}

class Unauthenticated extends AuthenticationState {
  @override
  List<Object> get props => [];
}