
class Email {
  final String value;

  const Email([this.value = ""]);

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  bool validate() {
    return _emailRegExp.hasMatch(this.value);
  }
}
