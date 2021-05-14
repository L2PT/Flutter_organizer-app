import 'package:flutter/material.dart';
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
}
