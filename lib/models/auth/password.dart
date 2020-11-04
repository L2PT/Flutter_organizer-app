import 'package:venturiautospurghi/utils/global_constants.dart';

enum PasswordValidationError { invalid }

class Password {

  final String value;

  const Password([this.value = ""]);

  static final _passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');

  bool validate() { 
    return Constants.debug || _passwordRegExp.hasMatch(this.value);
  }
}
