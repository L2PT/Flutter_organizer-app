part of 'login_cubit.dart';

enum _formStatus { valid, invalid, emailInvalid, passwordInvalid, phoneInvalid, loading, success, failure }
enum _loginView { email, phone }

class LoginState extends Equatable {
  const LoginState({
    this.email = const Email(),
    this.password = const Password(),
    this.phone = const Phone(),
    this.status = _formStatus.invalid,
    this.loginView = _loginView.email,
  });

  final Email email;
  final Password password;
  final Phone phone;
  final _formStatus status;
  final _loginView loginView;

  @override
  List<Object> get props => [email, phone, password, status, loginView];

  LoginState assign({
    Email? email,
    Password? password,
    Phone? phone,
    _formStatus? status,
    _loginView? loginView,
  }) {
    return LoginState(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      status: status ?? (
          (loginView ?? this.loginView) == _loginView.email?
          (!string.isNullOrEmpty((email ?? this.email).value) && !string.isNullOrEmpty((password ?? this.password).value)?
            ( email ?? this.email).validate() ?
                ((password ?? this.password).validate() ? _formStatus.valid
                : _formStatus.passwordInvalid)
              : _formStatus.emailInvalid
            : _formStatus.invalid)
          : !string.isNullOrEmpty(( phone ?? this.phone).value) ?
            ( phone ?? this.phone).validate() ? _formStatus.valid
              : _formStatus.phoneInvalid
            : _formStatus.invalid),
      loginView: loginView ?? this.loginView
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
  
  bool isPhoneInvalid() =>
    this.status == _formStatus.phoneInvalid;

  bool isLoading() =>
    this.status == _formStatus.loading;

  bool isSuccess() =>
    this.status == _formStatus.valid;

  bool isFailure() =>
    this.status == _formStatus.failure;
  
  bool isEmailLoginView() =>
    this.loginView == _loginView.email;

  bool isPhoneLoginView() =>
    this.loginView == _loginView.phone;

}
