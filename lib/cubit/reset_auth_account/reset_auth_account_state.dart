part of 'reset_auth_account_cubit.dart';

abstract class ResetAuthAccountState extends Equatable {
  const ResetAuthAccountState();
}

class AuthMethodSelectionState extends ResetAuthAccountState {
  @override
  List<Object> get props => [];
}

class CodeVerificationState extends ResetAuthAccountState {
  final String phoneNumber;
  final String code;

  CodeVerificationState(this.phoneNumber, this.code);

  @override
  List<Object> get props => [phoneNumber, code];
}
class CodeVerifiedState extends ResetAuthAccountState {
  @override
  List<Object> get props => [];
}
