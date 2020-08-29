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
extension ListExtensions on Iterable {
  @override
  //TODO to test
  List<List<T>> groupBy<T, Y>(Y Function(dynamic) fn) {
    Map<Y,List<T>> a = Map.fromIterable(this, key: fn, value: (e)=>List());
    this.map((element)=>{ a[element].add(element) });
    return a.values.toList();
  }
  @override
  //TODO to test
  Map<Y,int> countBy<Y>(Y Function(dynamic) fn) {
    Map<Y,int> a = Map();
    this.forEach((element) {
      Y key = fn(element);
      a[key] = (a[key] ?? 0) +1;
    });
    return a;
  }
}
