import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:flutter/src/material/pickers/date_picker_dialog.dart' as date_picker;
import 'package:flutter/src/material/time_picker.dart' as time_picker;

class PlatformDatePicker {

  static Theme dialog_theme(BuildContext context, Widget child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light().copyWith(
          primary: black,
        ),
      ),
      child: child,
    );
  }

  
  
  ///
  /// Display date picker bottom sheet.
  ///
  static Future<DateTime> showDatePicker(
      BuildContext context, {
        DateTime minTime,
        DateTime maxTime,
        Function onConfirm,
        DateTime currentTime,
      }) async {
      minTime = minTime??DateTime(1980);

      DateTime date = await date_picker.showDatePicker(
          context: context,
          firstDate: minTime,
          helpText: "Seleziona una data".toUpperCase(),
          cancelText: "Annulla".toUpperCase(),
          initialDate: currentTime ?? DateTime.now(),
          lastDate: maxTime,
          builder: dialog_theme
      );
      if (date != null) return onConfirm(date);
  }

  ///
  /// Display time picker bottom sheet.
  ///
  static Future<DateTime> showTimePicker(
      BuildContext context, {
        Function onConfirm,
        DateTime currentTime,
      }) async {

      TimeOfDay time = await time_picker.showTimePicker(
        context: context,
        helpText: "Seleziona un'orario".toUpperCase(),
        cancelText: "Annulla".toUpperCase(),
        initialTime: TimeOfDay.fromDateTime(currentTime ?? DateTime.now()),
        builder: dialog_theme,
      );
      if(time != null) return onConfirm(time);
  }

}