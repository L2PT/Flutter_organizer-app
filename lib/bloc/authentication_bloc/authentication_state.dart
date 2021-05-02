part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
  
  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState{
  
}

class Unauthenticated extends AuthenticationState {

}

class Unavailable extends AuthenticationState {

}

class Authenticated extends AuthenticationState {
  final Account user;
  final bool isSupervisor;
  final List<dynamic> tokens;

  Authenticated(this.user,this.isSupervisor, [tokens]) : this.tokens = tokens ?? [], super();

  @override
  List<Object> get props => [this.user,this.isSupervisor,this.tokens];
}

class Reset extends AuthenticationState {
  final String autofilledEmail;
  final String autofilledPhone;

  Reset(this.autofilledEmail, this.autofilledPhone) : super();

  @override
  List<Object> get props => [autofilledEmail, autofilledPhone];
}