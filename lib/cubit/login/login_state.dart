part of 'login_cubit.dart';

enum _formStatus { valid, invalid, emailInvalid, passwordInvalid, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.email = const Email(),
    this.password = const Password(),
    this.status = _formStatus.invalid,
  });

  final Email email;
  final Password password;
  final _formStatus status;

  @override
  List<Object> get props => [email, password, status];

  LoginState assign({
    Email email,
    Password password,
    _formStatus status,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? (( email ?? this.email) != null && (password ?? this.password) != null ?
        ( email ?? this.email).validate() ?
            ((password ?? this.password).validate() ? _formStatus.valid
            : _formStatus.passwordInvalid)
          : _formStatus.emailInvalid
        : _formStatus.invalid)
    );
  }

  bool isInvalid() =>
    this.status == _formStatus.invalid;

  bool isValid() =>
    this.status == _formStatus.valid;

  bool isEmailInvalid() =>
    this.status == _formStatus.emailInvalid;

  bool isPasswordInvalid() =>
    this.status == _formStatus.passwordInvalid;

  bool isLoading() =>
    this.status == _formStatus.loading;

  bool isSuccess() =>
    this.status == _formStatus.valid;

  bool isFailure() =>
    this.status == _formStatus.failure;

}
