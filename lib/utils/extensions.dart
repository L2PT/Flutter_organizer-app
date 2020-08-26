extension CheckNullabilityExtension on String {
  bool isNullOrEmpty() {
    return this == null || this == "";
  }
}
extension DateTimeExtensions on DateTime {
  @override
  String Stringify() {
    return this.year.toString() + '-' + ((this.month/10<1)?"0"+this.month.toString():this.month.toString()) + '-' + ((this.day/10<1)?"0"+this.day.toString():this.day.toString());
  }

  //LONGTERMTODO static extension is a working on for flutter team
  @override
  DateTime OlderBetween(DateTime compare) {
    if(this.isAfter(compare))
      return this;
    else
      return compare;
  }
}
