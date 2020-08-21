extension CheckNullabilityExtension on String {
  bool isNullOrEmpty() {
    return this == null || this == "";
  }
}
extension StringifyExtension on DateTime {
  @override
  String Stringify() {
    return this.year.toString() + '-' + ((this.month/10<1)?"0"+this.month.toString():this.month.toString()) + '-' + ((this.day/10<1)?"0"+this.day.toString():this.day.toString());
  }
}
