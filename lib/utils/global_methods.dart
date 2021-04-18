library app.utils;

import 'package:cloud_functions/cloud_functions.dart';
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

  static DateTime getNextWorkTimeSpan([DateTime? date]) {
    date = date ?? DateTime.now();

    DateTime nextWorkTime = date.add(new Duration(minutes: Constants.WORKTIME_SPAN));
    if(nextWorkTime.hour > Constants.MAX_WORKTIME){
      nextWorkTime.add(new Duration(days: 1));
      nextWorkTime = new DateTime(nextWorkTime.year,nextWorkTime.month, nextWorkTime.day, Constants.MIN_WORKTIME);
    }else if(nextWorkTime.hour < Constants.MIN_WORKTIME) {
      nextWorkTime = new DateTime(nextWorkTime.year,nextWorkTime.month, nextWorkTime.day, Constants.MIN_WORKTIME);
    }
    return nextWorkTime;
  }

  static DateTime addWorkTime(DateTime time, {int? hour, int? minutes}) {
    DateTime nextTimeWork = time.add(new Duration(hours: hour ?? 0, minutes: minutes ?? 0));
    if(nextTimeWork.hour > Constants.MAX_WORKTIME){
      nextTimeWork.add(new Duration(days: 1));
      nextTimeWork = new DateTime(nextTimeWork.year,nextTimeWork.month, nextTimeWork.day, Constants.MIN_WORKTIME);
    }else if(nextTimeWork.hour < Constants.MIN_WORKTIME){
      nextTimeWork = new DateTime(nextTimeWork.year,nextTimeWork.month, nextTimeWork.day, Constants.MIN_WORKTIME);
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
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
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
    var result = await GooglePlace(Constants.googleMapsApiKey).autocomplete.get(address);
    if(result != null && result.predictions != null)
      result.predictions!.forEach((e) => {
        if(!string.isNullOrEmpty(e.description))
          locations.add(e.description!)
      });
    return locations;
  }

  static Future getLocationsWeb(String address) async {
    List<String> locations = [];
    String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='+address+'&country=it&language=it&key='+Constants.googleMapsApiKey;
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
