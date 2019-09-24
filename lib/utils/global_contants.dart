library App.globals;
import 'package:venturiautospurghi/models/event_model.dart';

class Constants {
  //Calendar related
  final Map<DateTime, List> holidays = {
    DateTime(2019, 1, 1): [new Event("New Year\'s Day", "", DateTime(2019, 1, 1),DateTime(2019, 1, 1),"","")],
    DateTime(2019, 1, 6): [new Event("Epiphany", "", DateTime(2019, 1, 6),DateTime(2019, 1, 6),"","")],
    DateTime(2019, 2, 14): [new Event("Valentine\'s Day", "", DateTime(2019, 2, 14),DateTime(2019, 2, 14),"","")],
    DateTime(2019, 4, 21): [new Event("Easter Sunday", "", DateTime(2019, 4, 21),DateTime(2019, 4, 21),"","")],
    DateTime(2019, 4, 22): [new Event("Easter Monday", "", DateTime(2019, 4, 22),DateTime(2019, 4, 22),"","")]
  };

  //Event related
  //TODO sarebbe bello averle su database queste categorie
  Map<String,int> category = {
    "Spurghi":0xFF0503FB,
    "Fogne":0xFF05F30B,
    "Tombini":0xFFC5032B,
  };

  // Flutter Routes
  static const String homeRoute = '/';
  static const String monthlyCalendarRoute = 'view/monthly_calendar';
  static const String dailyCalendarRoute = 'view/daily_calendar';
  static const String operatorListRoute = 'view/op_list';
  static const String detailsEventViewRoute = 'view/details_event';
  static const String formEventCreatorRoute = 'view/form_event_creator';
  static const String waitingEventListRoute = 'view/waiting_event_list';
  static const String profileRoute = 'view/profile';
  static const String resetCodeRoute = 'view/reset_code_page';
  static const String logInRoute = 'view/log_in';
  static const String logOut = 'log_out';
  static bool debug = false;

}