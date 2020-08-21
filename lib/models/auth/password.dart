enum PasswordValidationError { invalid }

class Password {

  final String value;

  const Password([this.value = ""]);

  static final _passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  bool validate() {
    return _passwordRegExp.hasMatch(this.value);
  }
}
