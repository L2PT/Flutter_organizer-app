
class Phone {
  final String value;

  const Phone([this.value = ""]);

  static final RegExp _phoneRegExp = RegExp(
      r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$'
  );

  bool validate() {
    return _phoneRegExp.hasMatch(this.value);
  }
}
