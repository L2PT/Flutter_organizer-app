import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class PlatformDatePicker {

  static Widget dialog_theme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light().copyWith(
          primary: black,
        ),
      ),
      child: child ?? Container(),
    );
  }
  
  ///
  /// Display date picker bottom sheet.
  ///
  static void selectDate(
      BuildContext context, {
        DateTime? minTime,
        DateTime? maxTime,
        required Function onConfirm,
        DateTime? currentTime,
      }) async {

      DateTime? date = await showDatePicker(
          context: context,
          firstDate: minTime ?? DateTime(1980),
          helpText: "Seleziona una data".toUpperCase(),
          cancelText: "Annulla".toUpperCase(),
          initialDate: currentTime ?? DateTime.now(),
          lastDate: maxTime ?? DateTime(3000),
          builder: dialog_theme
      );
      if (date != null) return onConfirm(date);
  }

  ///
  /// Display time picker bottom sheet.
  ///
  static void selectTime(
      BuildContext context, {
        required Function onConfirm,
        DateTime? currentTime,
      }) async {

      TimeOfDay? time = await showTimePicker(
        context: context,
        helpText: "Seleziona un'orario".toUpperCase(),
        cancelText: "Annulla".toUpperCase(),
        initialTime: TimeOfDay.fromDateTime(currentTime ?? DateTime.now()),
        builder: dialog_theme,
      );
      if(time != null) return onConfirm(time);
  }

}