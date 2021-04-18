import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/filter_widget.dart';
import 'package:venturiautospurghi/views/widgets/platform_datepicker.dart';

class OperatorsFilterWidget extends FilterWidget{

  final DateTime searchTimeField;
  final void Function(DateTime) onSearchDateChanged;
  final void Function(DateTime) onSearchTimeChanged;

  OperatorsFilterWidget({
    bool filtersBoxVisibile = false,
    bool showIconExpanded = true,
    required void Function()? showFiltersBox,
    required void Function(String) onSearchChanged,
    bool isWebMode = false,
    String hintTextSearch = '',
    required this.searchTimeField,
    required this.onSearchDateChanged,
    required this.onSearchTimeChanged,
  }) : super(
      filtersBoxVisibile: filtersBoxVisibile,
      showIconExpanded: showIconExpanded,
      showFiltersBox: showFiltersBox,
      onSearchChanged: onSearchChanged,
      hintTextSearch: hintTextSearch,
      isWebMode: isWebMode,
      showActionFilters: false,
  );

  @override
  Widget filterBox(BuildContext context) {
    DateFormat formatDate = DateFormat('E d MMM y','it_IT');
    return  Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.tune),
              SizedBox(width: 5,),
              Text("FILTRA", style: subtitle_rev),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 3.0),
            child: Text("Operatori liberi", style: subtitle_rev.copyWith(fontWeight: FontWeight.normal)),
          ),
          Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(children: [
                      Icon(Icons.date_range),
                      SizedBox(width: 5),
                      GestureDetector(
                        child: Text(formatDate.format(searchTimeField), style: time_card),
                        onTap: () =>
                            PlatformDatePicker.selectDate(context,
                              maxTime: DateTime(3000),
                              currentTime: searchTimeField,
                              onConfirm: (date) => onSearchDateChanged(date),
                            ),
                      ),
                    ],
                  ),
                  Row( children: [
                    Icon(Icons.watch_later),
                    SizedBox(width: 5),
                    GestureDetector(
                      child: Text(searchTimeField.toString().split(' ').last.split('.').first.substring(0, 5), style: time_card),
                      onTap: () =>
                          PlatformDatePicker.selectTime(context,
                            currentTime: searchTimeField,
                            onConfirm: (date) => onSearchTimeChanged(date),
                          ),
                    )
                  ]),
                ],
              ))
        ]);
  }

}