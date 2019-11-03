library App.globals;
import 'package:venturiautospurghi/models/event.dart';

class Constants {
  static const String title = "Venturi Autospurghi App";
  static bool debug = false;
  static const String web = "web";
  static const String mobile = "mobile";


  static const int fallbackColor = 0xFF119DD1;
  static const String fallbackHexColor = "#FDA90A";

  //Calendar related
  final Map<DateTime, List> holidays = {
    //DateTime(2019, 1, 1): [new Event("New Year\'s Day", "", DateTime(2019, 1, 1),DateTime(2019, 1, 1),"","")],
    //DateTime(2019, 1, 6): [new Event("Epiphany", "", DateTime(2019, 1, 6),DateTime(2019, 1, 6),"","")],
    //DateTime(2019, 2, 14): [new Event("Valentine\'s Day", "", DateTime(2019, 2, 14),DateTime(2019, 2, 14),"","")],
    //DateTime(2019, 4, 21): [new Event("Easter Sunday", "", DateTime(2019, 4, 21),DateTime(2019, 4, 21),"","")],
    //DateTime(2019, 4, 22): [new Event("Easter Monday", "", DateTime(2019, 4, 22),DateTime(2019, 4, 22),"","")]
  };

  // ROUTES
  static const String homeRoute = '/';
  static const String monthlyCalendarRoute = 'view/monthly_calendar';
  static const String dailyCalendarRoute = 'view/daily_calendar';
  static const String operatorListRoute = 'view/op_list';
  static const String registerRoute = 'view/register';
  static const String detailsEventViewRoute = 'view/details_event';
  static const String formEventCreatorRoute = 'view/form_event_creator';
  static const String waitingEventListRoute = 'view/waiting_event_list';
  static const String profileRoute = 'view/profile';
  static const String resetCodeRoute = 'view/reset_code_page';
  static const String logInRoute = 'view/log_in';
  static const String logOut = 'log_out';

  // TABLES DATABASE
  static const String tabellaUtenti = 'Utenti';
  static const String tabellaEventi = 'Eventi';
  static const String tabellaEventiEliminati = '/Storico/StoricoEventi/EventiEliminati';
  static const String tabellaEventiTerminati = '/Storico/StoricoEventi/EventiTerminati';
  static const String tabellaEventiRifiutati = '/Storico/StoricoEventi/EventiRifiutati';
  static const String tabellaCostanti = 'Costanti';
  // TABLE EVENTI
  static const String tabellaEventi_categoria = 'Categoria';
  static const String tabellaEventi_dataFine = 'DataFine';
  static const String tabellaEventi_dataInizio = 'DataInizio';
  static const String tabellaEventi_desc = 'Descrizione';
  static const String tabellaEventi_luogo = 'Luogo';
  static const String tabellaEventi_ope = 'Operatore';
  static const String tabellaEventi_resp = 'Responsabile';
  static const String tabellaEventi_stato = 'Stato';
  static const String tabellaEventi_subOpe = 'SubOperatori';
  static const String tabellaEventi_titolo = 'Titolo';
  static const String tabellaEventi_motivazione = 'Motivazione';

  // INSIDE EVENTS SWITCHES
  static const int EVENTS_BLOC = 0;
  static const int OPERATORS_BLOC = 1;
  static const int OUT_OF_BLOC = 2;

  static const String DELETE_SIGNAL = "delete_event_signal";
  static const String MODIFY_SIGNAL = "modify_event_signal";

  static const MIN_WORKHOUR_SPAN = 6;
  static const MAX_WORKHOUR_SPAN = 21;
  static const WORKHOUR_SPAN = 30;



}