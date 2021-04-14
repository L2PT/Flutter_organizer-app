import 'package:flutter/material.dart';

class EventStatus {
  static const int Refused = -2;
  static const int Deleted = -1;
  static const int New = 0;
  static const int Delivered = 1;
  static const int Seen = 2;
  static const int Accepted = 3;
  static const int Ended = 4;

  static IconData getIcon(int status){
    switch(status){
      case Deleted:
        return Icons.delete;
      case New:
        return Icons.assignment;
      case Delivered:
        return Icons.assignment_returned;
      case Seen:
        return Icons.assignment_ind;
      case Accepted:
        return Icons.assignment_turned_in;
      case Refused:
        return Icons.assignment_late;
      case Ended:
        return Icons.assistant_photo;
      default: return Icons.assignment;
    }
  }

  static String getText(int status){
    switch(status){
      case EventStatus.Deleted: return "Eliminato";
      case EventStatus.New: return "Nuovo";
      case EventStatus.Delivered: return "Consegnato";
      case EventStatus.Seen: return "Visualizzato";
      case EventStatus.Accepted: return "Accettato";
      case EventStatus.Refused: return "Rifiutato";
      case EventStatus.Ended: return "Terminato";
      default: return "Nuovo";
    }
  }

  static String getTextHistory(int status){
    switch(status){
      case EventStatus.Deleted: return "Eliminati";
      case EventStatus.Refused: return "Rifiutati";
      default: return "Conclusi";
    }
  }
}
