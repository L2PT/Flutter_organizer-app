part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState{
  AuthenticationState() : super();
}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final dynamic user;
  final bool isSupervisor;

  Authenticated([this.user,this.isSupervisor]);

  @override
  List<Object> get props => [this.user,this.isSupervisor];
}

class Unauthenticated extends AuthenticationState {}
