import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/base_alert.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/src/material/pickers/date_picker_dialog.dart' as web_dd;
import 'package:flutter/src/material/time_picker.dart' as web_dt;

class PlatformDatePicker {

  static Theme web_theme(BuildContext context, Widget child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light().copyWith(
          primary: black,
        ),
      ),
      child: child,
    );
  }
  
  static DatePickerTheme mobile_theme = DatePickerTheme(
      headerColor: black,
      backgroundColor: white,
      itemStyle: label,
      cancelStyle: subtitle,
      doneStyle: subtitle_accent
  );
  
  
  ///
  /// Display date picker bottom sheet.
  ///
  static Future<DateTime> showDatePicker(
      BuildContext context, {
        bool showTitleActions: true,
        DateTime minTime,
        DateTime maxTime,
        Function onChanged,
        Function onConfirm,
        DateCancelledCallback onCancel,
        locale: LocaleType.en,
        DateTime currentTime,
      }) async {
    if(PlatformUtils.isMobile)
      return DatePicker.showDatePicker(context,
        showTitleActions: showTitleActions,
        minTime: minTime,
        maxTime: maxTime,
        theme: mobile_theme,
        currentTime: currentTime ?? DateTime.now(),
        locale: locale,
        onConfirm: onConfirm,
      );
    else {
      DateTime date = await web_dd.showDatePicker(
          context: context,
          firstDate: minTime,
          helpText: "Seleziona una data".toUpperCase(),
          cancelText: "Annulla".toUpperCase(),
          initialDate: currentTime ?? DateTime.now(),
          lastDate: maxTime,
          builder: web_theme
      );
      if (date != null) return onConfirm(date);
    }
  }

  ///
  /// Display time picker bottom sheet.
  ///
  static Future<DateTime> showTimePicker(
      BuildContext context, {
        bool showTitleActions: true,
        bool showSecondsColumn: true,
        Function onChanged,
        Function onConfirm,
        DateCancelledCallback onCancel,
        locale: LocaleType.en,
        DateTime currentTime,
      }) async {
    if(PlatformUtils.isMobile) {
      return DatePicker.showTimePicker(context,
        showTitleActions: showTitleActions,
        theme: mobile_theme,
        currentTime: currentTime ?? DateTime.now(),
        locale: locale,
        onConfirm: onConfirm,
      );
    } else {
      TimeOfDay time = await web_dt.showTimePicker(
        context: context,
        helpText: "Seleziona un'orario".toUpperCase(),
        cancelText: "Annulla".toUpperCase(),
        initialTime: TimeOfDay.fromDateTime(currentTime ?? DateTime.now()),
        builder: web_theme
      );
      if(time != null) return onConfirm(time);
    }
  }

}