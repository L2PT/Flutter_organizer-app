library App.utils;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/backdrop_bloc/backdrop_bloc.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/view/widget/dialog_app.dart';

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
}

class Utils {

  static Future<Map<String,dynamic>> getCategories() async {
    Map <String,dynamic> categories;
    var doc = await PlatformUtils.fireDocument(global.Constants.tabellaCostanti, "Categorie").get();
    if (doc.exists) {
      categories = PlatformUtils.extractFieldFromDocument(null, doc);
      categories['default'] = global.Constants.fallbackHexColor;
    } else {
      print("No categories!");
    }
    return categories;
  }

  static Future<Color> getColor(arg) async {
    Map <String,dynamic> categories;
    var doc = await PlatformUtils.fireDocument(global.Constants.tabellaCostanti, "Categorie").get();
    if (doc.exists) {
      categories = PlatformUtils.extractFieldFromDocument(null, doc);
      categories['default'] = global.Constants.fallbackHexColor;
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
    day = day.add(Duration(hours: global.Constants.MIN_WORKHOUR_SPAN));
    Event event = Event.empty();
    event.start = day;
    event.end = day.add(Duration(minutes: global.Constants.WORKHOUR_SPAN));
    return event;
  }

  static bool isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  static void notify({token="eGIwmXLpg_c:APA91bGkJI5Nargw6jjiuO9XHxJYcJRL1qfg0CjmnblAsZQ8k-kPQXCCkalundHtsdS21_clryRplzXaSgCj6PM1geEmXttijdSCWQuMQWUHpjPZ9nJOaNFqC6Yq6Oa5WixzyObXr8gt",
                      title="Nuovo incarico assegnato",
                      description="Clicca la notifica per vedere i dettagli",
                      eventId=""}) async {
    String url = "https://fcm.googleapis.com/fcm/send";
    String json = "";
    Map<String,String> not = new Map<String,String>();
    Map<String,String> data = new Map<String,String>();
    json = "{\"to\":\"${token}\",";
    not['title'] = title;
    not['body'] = description;
    not['click_action'] = "FLUTTER_NOTIFICATION_CLICK";
    data['id'] = eventId;
    json += "\"notification\":"+jsonEncode(not)+", \"data\":"+jsonEncode(data)+"}";
    var response = await http.post(url, body: json, headers: {"Authorization": "key=AIzaSyBF13XNJM1LDuRrLcWdQQxuEcZ5TakypEk","Content-Type": "application/json"},encoding: Encoding.getByName('utf-8'));
    print("response: "+jsonEncode(json));
    print("response: "+response.body);
  }

  static void PushViewDetailsEvent(BuildContext context, Event ev) async {
    final result = await Navigator.pushNamed(context, global.Constants.detailsEventViewRoute, arguments: ev);
    if(result == global.Constants.DELETE_SIGNAL) {
      EventsRepository().deleteEvent(ev);
    }
    if(result == global.Constants.MODIFY_SIGNAL) {
      Navigator.pushNamed(context, global.Constants.createEventViewRoute, arguments: ev);
    }
  }

  static void deleteDialog(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return dialogAlert(
            action: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: new Text('Annulla', style: label),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.canPop(context)?Navigator.of(context).pop():null;
                    },
                  ),
                  SizedBox(width: 15,),
                  RaisedButton(
                    child: new Text('CONFERMA', style: button_card),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(15.0))),
                    color: black,
                    elevation: 15,
                    onPressed: () {
                      Navigator.pop(context,false);
                      Navigator.pop(context, global.Constants.DELETE_SIGNAL);
                      Navigator.canPop(context)?Navigator.pop(context, global.Constants.DELETE_SIGNAL):null;
                    },
                  ),
                ]),
            content:  SingleChildScrollView(
              child: ListBody(children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text("Confermi la cancellazione dell'incarico?", style: label,),
                ),
              ]),
            ),
            tittle: "CANCELLA INCARICO",
            context: context,
          );
        });
  }

  static void NavigateTo(BuildContext context, String route, dynamic arg){
//    BlocProvider.of<BackdropBloc>(context).add(NavigateEvent(route,arg));
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