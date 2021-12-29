library app.utils;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:google_place/google_place.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

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

  static DateTime getNextStartWorkTimeSpan({DateTime? from, Duration? ofDuration}) {
    DateTime date = from ?? DateTime.now();

    DateTime nextWorkTime = TimeUtils.addWorkTime(date, new Duration(minutes: Constants.WORKTIME_SPAN));
    return getStartWorkTimeSpan(from:nextWorkTime, ofDuration: ofDuration);
  }

  static DateTime getStartWorkTimeSpan({required DateTime from, Duration? ofDuration}) {
    Duration duration = ofDuration ?? Duration(minutes: Constants.WORKTIME_SPAN);

    DateTime startTimePeriod = from.add(duration);
    if(from.day != startTimePeriod.day || startTimePeriod.hour > Constants.MAX_WORKTIME || (startTimePeriod.hour == Constants.MAX_WORKTIME && startTimePeriod.minute > 0))
      startTimePeriod = TimeUtils.truncateDate(from, "day").add(new Duration(days: 1, hours: Constants.MIN_WORKTIME));
    else if(from.hour < Constants.MIN_WORKTIME){
      startTimePeriod = TimeUtils.truncateDate(startTimePeriod, "day").add(new Duration(hours: Constants.MIN_WORKTIME));
    }
    return startTimePeriod;
  }

  static DateTime addWorkTime(DateTime time,  Duration duration) {
    DateTime nextTimeWork = time.add(duration);
    if(nextTimeWork.hour > Constants.MAX_WORKTIME || (nextTimeWork.hour == Constants.MAX_WORKTIME && nextTimeWork.minute > 0)){
      nextTimeWork = TimeUtils.truncateDate(time, "day").add(new Duration(days: 1, hours: Constants.MIN_WORKTIME));
    }else if(nextTimeWork.hour < Constants.MIN_WORKTIME){
      nextTimeWork = TimeUtils.truncateDate(nextTimeWork, "day").add(new Duration(hours: Constants.MIN_WORKTIME));
    }
    return nextTimeWork;
  }
}

class Utils {

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

  static bool isPhoneNumber(String str) {
    String patttern = r'(^(?:[+3]9)?[0-9]{8,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (str.length == 0) {
      return false;
    }
    else if (!regExp.hasMatch(str)) {
      return false;
    }
    return true;
  }
}

class GeoUtils {

  static Future<List<String>>  getLocations(String address) async {
    List<String> locations = [];
    var result = await GooglePlace(Constants.googleMapsApiKey).autocomplete.get(address, language: "it",
        components: [new Component("country", "it")] );
    if(result != null && result.predictions != null)
      result.predictions!.forEach((e) => {
        if(!string.isNullOrEmpty(e.description))
          locations.add(e.description!)
      });
    return locations;
  }

  static Future getLocationsWeb(String address) async {
    List<String> locations = [];
    String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='+address+'&country=it&components=country:it&language=it&key='+Constants.googleMapsApiKey;
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'getDataFromUrl',);
    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'url': url,
        },
      );
      List predictions = result.data['predictions'];
      predictions.forEach((address) {
        locations.add(address['description']);
      });
      return locations;
    } on FirebaseFunctionsException catch (e) {
      print('caught firebase functions exception');
      print(e.code);
      print(e.message);
      print(e.details);
      return null;
    } catch (e) {
      print('caught generic exception');
      print(e);
      return null;
    }
  }

}
