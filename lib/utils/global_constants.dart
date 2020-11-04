library App.globals;
import 'package:flutter/foundation.dart';

class Constants {
  static const String title = "Venturi Autospurghi App";
  static const bool debug = !bool.fromEnvironment('dart.vm.product');
  static const String web = "web";
  static const String mobile = "mobile";

  static const String passwordNewUsers = "adminVenturi";
  static const int fallbackColor = 0xFF119DD1;
  static const String fallbackHexColor = "#FDA90A";

  // ROUTES
  static const String homeRoute = '/';
  static const String monthlyCalendarRoute = 'view/monthly_calendar';
  static const String dailyCalendarRoute = 'view/daily_calendar';
  static const String operatorListRoute = 'view/op_list';
  static const String addWebOperatorRoute = 'view/op_web_list';
  static const String registerRoute = 'view/register';
  static const String detailsEventViewRoute = 'view/details_event';
  static const String createEventViewRoute = 'view/form_event_creator';
  static const String waitingEventListRoute = 'view/waiting_event_list';
  static const String waitingNotificationRoute = 'view/persistent_notification';
  static const String historyEventListRoute = 'view/history_event_list';
  static const String profileRoute = 'view/profile';
  static const String resetCodeRoute = 'view/reset_code_page';
  static const String logInRoute = 'view/log_in';
  static const String logOut = 'log_out';

  // TABLES DATABASE
  static const String tabellaUtenti = 'Utenti';
  static const String tabellaCostanti = debug?'Costanti_DEBUG':'Costanti';
  static const String tabellaEventi = debug?'Eventi_DEBUG':'Eventi';
  static const String tabellaStorico = debug?'Storico_DEBUG':'Storico';
  static const String subtabellaStorico = debug?'StoricoEventi_DEBUG':'StoricoEventi';
  static const String tabellaEventiEliminati = debug?'/Storico_DEBUG/StoricoEliminati/StoricoEventi_DEBUG':'/Storico/StoricoEliminati/StoricoEventi';
  static const String tabellaEventiTerminati = debug?'/Storico_DEBUG/StoricoTerminati/StoricoEventi_DEBUG':'/Storico/StoricoTerminati/StoricoEventi';
  static const String tabellaEventiRifiutati = debug?'/Storico_DEBUG/StoricoRifiutati/StoricoEventi_DEBUG':'/Storico/StoricoRifiutati/StoricoEventi';

  // TABLE EVENTI
  static const String tabellaEventi_titolo = 'Titolo';
  static const String tabellaEventi_descrizione = 'Descrizione';
  static const String tabellaEventi_dataFine = 'DataFine';
  static const String tabellaEventi_dataInizio = 'DataInizio';
  static const String tabellaEventi_indirizzo = 'Indirizzo';
  static const String tabellaEventi_stato = 'Stato';
  static const String tabellaEventi_categoria = 'Categoria';
  static const String tabellaEventi_motivazione = 'Motivazione';
  static const String tabellaEventi_luogo = 'Luogo';
  static const String tabellaEventi_idOperatore = 'IdOperatore';
  static const String tabellaEventi_idOperatori = 'IdOperatori';
  static const String tabellaEventi_idResponsabile = 'IdResponsabile';
  static const String tabellaEventi_operatore = 'Operatore';
  static const String tabellaEventi_subOperatori = 'SubOperatori';
  static const String tabellaEventi_responsabile = 'Responsabile';

  // TABLE COSTANTI
  static const String tabellaCostanti_Categorie = 'Categorie';
  static const String tabellaCostanti_Telefoni = 'Telefoni';

  // HANDLES
  static const int MIN_WORKTIME = 6;
  static const int MAX_WORKTIME = 21;
  static const int WORKTIME_SPAN = 30;
  static const double MIN_CALENDAR_EVENT_HEIGHT = 60.0;

  static const String googleMapsApiKey = 'AIzaSyD3A8jbx8IRtXvnmoGSwJy2VyRCvo0yjGk';



}