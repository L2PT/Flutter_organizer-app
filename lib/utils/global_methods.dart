library App.utils;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';

class TimeUtils {

  static DateTime truncateDate(DateTime date, String format) {
    int year = date.year,
        month = 1,
        day = 1;
    if (format == "month" || format == "day") month = date.month;
    if (format == "day") day = date.day;
    String truncatedDate = year.toString() + '-' + ((month / 10 < 1) ? "0" + month.toString() : month.toString()) +
        '-' + ((day / 10 < 1) ? "0" + day.toString() : day.toString());
    return DateTime.parse(truncatedDate);
  }
//TODO ragiona sul now e le ore lavorative [Constants.MIN_WORKTIME] -> [Constants.MAX_WORKTIME] e [Constants.WORKTIME_SPAN]
  //il paramtro va inteso come max(date, now)
  static DateTime getNextWorkTimeSpan([DateTime date]) {
    if(date == null){
      date = DateTime.now();
    }
    DateTime nextTimeWork = date.add(new Duration(minutes: Constants.WORKTIME_SPAN));
    if(nextTimeWork.hour > Constants.MAX_WORKTIME){
      nextTimeWork.add(new Duration(days: 1));
      return new DateTime(nextTimeWork.year,nextTimeWork.month, nextTimeWork.day, Constants.MIN_WORKTIME);
    }else if(nextTimeWork.hour < Constants.MIN_WORKTIME){
      return new DateTime(nextTimeWork.year,nextTimeWork.month, nextTimeWork.day, Constants.MIN_WORKTIME);
    }else{
      return nextTimeWork;
    }
  }


  //TODO ragiona sul time e le ore lavorative [Constants.MIN_WORKTIME] -> [Constants.MAX_WORKTIME]

  static DateTime addWorkTime(DateTime time, {int hour, int minutes}) {
    DateTime nextTimeWork;
    if(hour != null){
      nextTimeWork = time.add(new Duration(hours: hour));
    }
    if(minutes != null){
      nextTimeWork = time.add(new Duration(minutes: minutes));
    }
    if(nextTimeWork.hour > Constants.MAX_WORKTIME){
      nextTimeWork.add(new Duration(days: 1));
      return new DateTime(nextTimeWork.year,nextTimeWork.month, nextTimeWork.day, Constants.MIN_WORKTIME);
    }else if(nextTimeWork.hour < Constants.MIN_WORKTIME){
    return new DateTime(nextTimeWork.year,nextTimeWork.month, nextTimeWork.day, Constants.MIN_WORKTIME);
    }else{
    return nextTimeWork;
    }
  }
}

class Utils {

  static Future<Color> getColor(arg) async {
    Map <String,dynamic> categories;
    var doc = await PlatformUtils.fireDocument(Constants.tabellaCostanti, "Categorie").get();
    if (doc.exists) {
      categories = PlatformUtils.extractFieldFromDocument(null, doc);
      categories['default'] = Constants.fallbackHexColor;
    } else {
      print("No categories!");
    }
    return HexColor((arg != null && categories[arg] != null)
        ? categories[arg]
        : categories['default']);
  }

  static Event getEventWithCurrentDay(DateTime day){
    day = TimeUtils.truncateDate(day, "day");
    if(DateTime.now().isAfter(day)) day = TimeUtils.truncateDate(DateTime.now(), "day");
    day = day.add(Duration(hours: Constants.MIN_WORKTIME));
    Event event = Event.empty();
    event.start = day;
    event.end = day.add(Duration(minutes: Constants.WORKTIME_SPAN));
    return event;
  }

  static bool isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  static void PushViewDetailsEvent(BuildContext context, Event ev) async {
    final result = await Navigator.pushNamed(context, Constants.detailsEventViewRoute, arguments: ev);
    if(result == Constants.DELETE_SIGNAL) {
      EventsRepository().deleteEvent(ev);
    }
    if(result == Constants.MODIFY_SIGNAL) {
      Navigator.pushNamed(context, Constants.createEventViewRoute, arguments: ev);
    }
  }

}
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}