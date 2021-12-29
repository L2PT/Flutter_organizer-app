import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class EventStatus {
  static const int Bozza = -3;
  static const int Deleted = -2;
  static const int Refused = -1;
  static const int New = 0;
  static const int Delivered = 1;
  static const int Seen = 2;
  static const int Accepted = 3;
  static const int Ended = 4;

  static IconData getIcon(int status){
    switch(status){
      case Bozza:
        return Icons.edit;
      case Deleted:
        return Icons.delete;
      case Refused:
        return Icons.assignment_late;
      case New:
        return Icons.assignment;
      case Delivered:
        return Icons.assignment_returned;
      case Seen:
        return Icons.assignment_ind;
      case Accepted:
        return Icons.assignment_turned_in;
      case Ended:
        return Icons.flag;
      default: return Icons.assignment;
    }
  }

  static String getText(int status){
    switch(status){
      case EventStatus.Bozza: return "Bozza";
      case EventStatus.Deleted: return "Eliminato";
      case EventStatus.Refused: return "Rifiutato";
      case EventStatus.New: return "Nuovo";
      case EventStatus.Delivered: return "Consegnato";
      case EventStatus.Seen: return "Visualizzato";
      case EventStatus.Accepted: return "Accettato";
      case EventStatus.Ended: return "Terminato";
      default: return "Nuovo";
    }
  }

  static String getCategoryText(int status){
    switch(status){
      case EventStatus.Deleted: return "Eliminati";
      case EventStatus.Refused: return "Rifiutati";
      default: return "Conclusi";
    }
  }

  static Color getColorStatus(int status){
    switch(status){
      case EventStatus.Refused: return colorRefused;
      case EventStatus.Accepted: return colorAccepted;
      case EventStatus.Deleted: return colorDeleted;
      case EventStatus.Ended: return black;
      default: return colorWaiting;
    }
  }

}
