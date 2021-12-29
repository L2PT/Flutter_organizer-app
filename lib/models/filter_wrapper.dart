import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class FilterWrapper {

  String fieldName = "";
  dynamic fieldValue = "";
  Function? filterFunction;

  FilterWrapper(this.fieldName, this.fieldValue, this.filterFunction);

  FilterWrapper update(newValue) => FilterWrapper(this.fieldName, newValue, this.filterFunction);

  @override
  String toString() {
    return 'FilterWrapper{fieldName: $fieldName, fieldValue: $fieldValue}';
  }

  static Map<String, FilterWrapper> initFilter(){
    // maybe we can put the dbconstants strings
    Map<String, FilterWrapper> filters = {
      "title": new FilterWrapper("title", null, (Event event, value) => value == null || event.title.toUpperCase().contains(value.toUpperCase()) ),
      "address" : new FilterWrapper("address", null, (Event event, value) => value == null || event.address.toUpperCase().contains(value.toUpperCase()) ),
      "phone" : new FilterWrapper("phone", null, (Event event, value) => value == null || event.customer.phone.toUpperCase().contains(value.toUpperCase()) ),
      "startDate" : new FilterWrapper("startDate", null, (Event event, value) => value == null || event.start.add(Duration(minutes: 1)).isAfter(value) ),
      "status" : new FilterWrapper("status", null, (Event event, value) => value == null || event.status == value),
      "endDate" : new FilterWrapper("endDate", null, (Event event, value) => value == null || value.add(Duration(minutes: 1)).isAfter(event.end) ),
      "categories" : new FilterWrapper("categories", <String,bool>{}, (Event event, List<String>? value) =>
      value == null || value.any((category) => category == event.category)),
      "suboperators" : new FilterWrapper("suboperators", <Account>[], (Event event, List<Account>? value) {
        if(value == null) return true;
        List<String> idOperators = [...event.suboperators.map((op) => op.id),event.operator?.id??""];
        if(value.every((element) => idOperators.contains(element.id))) return true;
        return false;
      })};

    return filters;
  }
}
