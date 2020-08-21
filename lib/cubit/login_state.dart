part of 'login_cubit.dart';

enum FormStatus { valid, invalid, emailInvalid, passwordInvalid, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.email = const Email(),
    this.password = const Password(),
    this.status = FormStatus.invalid,
  });

  final Email email;
  final Password password;
  final FormStatus status;

  @override
  List<Object> get props => [email, password, status];

  LoginState assign({
    Email email,
    Password password,
    FormStatus status,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? (( email ?? this.email) != null && (password ?? this.password) != null ?
        ( email ?? this.email).validate() ?
            ((password ?? this.password).validate() ? FormStatus.valid
            : FormStatus.passwordInvalid)
          : FormStatus.emailInvalid
        : FormStatus.invalid)
    );
  }

  bool isInvalid() =>
    this.status == FormStatus.invalid;

  bool isValid() =>
    this.status == FormStatus.valid;

  bool isEmailInvalid() =>
    this.status == FormStatus.emailInvalid;

  bool isPasswordInvalid() =>
    this.status == FormStatus.passwordInvalid;

  bool isLoading() =>
    this.status == FormStatus.loading;

  bool isSuccess() =>
    this.status == FormStatus.valid;

  bool isFailure() =>
    this.status == FormStatus.failure;

}
