part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {
  
}

class LoggedOut extends AuthenticationEvent {

}

class LoggedIn extends AuthenticationEvent {
  final AuthUser user;

  LoggedIn(this.user) : super();

  @override
  List<Object> get props => [user];
}

class ResetAction extends AuthenticationEvent {
  final String email;
  final String phone;

  ResetAction(this.email, this.phone) : super();

  @override
  List<Object> get props => [email, phone];
}

