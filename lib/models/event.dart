import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';

class Event {
  String _id = "";
  String _title = "";
  String _description = "";
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  String _address = "";
  List<dynamic> _documents = new List();
  int _status = Status.New;
  String _category = "";
  String _color = "";
  String _motivazione = "";
  dynamic _supervisor = null;
  dynamic _operator = null;
  List<dynamic> _suboperators = new List();


  Event(this._id, this._title, this._description, this._start, this._end, this._address, this._documents, this._status, this._category, this._color, this._supervisor, this._operator, this._suboperators, this._motivazione);
  Event.empty();
  Event.fromMapWeb(String id, String color, dynamic json){
//    _id = (id!=null && id!="")?id:(json.id!=null)?json.id:"";
//    _title = json.Titolo;
//    _description = json.Descrizione;
//    _start = new DateTime.fromMillisecondsSinceEpoch(json.DataInizio.seconds*1000);
//    _end = new DateTime.fromMillisecondsSinceEpoch(json.DataFine.seconds*1000);
//    _address = json.Indirizzo;
//    _documents = json.Documenti;
//    _status = json.Stato;
//    _category = json.Categoria;
//    _motivazione = json.Motivazione;
//    _color = (color!=null && color!="")?color:(json.color!=null)?json.color:"";
//    _supervisor = PlatformUtils.AccountFromMap("d", json.Responsabile).toDocument();
//    _operator = PlatformUtils.AccountFromMap("d", json.Operatore).toDocument();
//    _suboperators = json.SubOperatori.map((op)=>PlatformUtils.AccountFromMap("d", op).toDocument()).toList();
  }

  Event.fromMap(String id, String color, Map json) :
    _id = (id!=null && id!="")?id:(json["id"]!=null)?json["id"]:"",
    _title = json["Titolo"],
    _description = json["Descrizione"],
    _start = json["DataInizio"] is DateTime?json["DataInizio"]:new DateTime.fromMillisecondsSinceEpoch(json["DataInizio"].seconds*1000),
    _end = json["DataFine"] is DateTime?json["DataFine"]:new DateTime.fromMillisecondsSinceEpoch(json["DataFine"].seconds*1000),
    _address = json["Indirizzo"],
    _documents = json["Documenti"]??[],
    _status = json["Stato"],
    _category = json["Categoria"],
    _color = (!color.isNullOrEmpty())?color:(json.containsKey("color"))?json["color"]:"",
    _supervisor = json["Responsabile"],
    _operator = json["Operatore"],
    _suboperators = json["SubOperatori"],
    _motivazione = json["Motivazione"];

  Map<String, dynamic> toMap() => {
      "id":this.id,
      "Titolo":this.title,
      "Descrizione":this.description,
      "DataInizio":this.start,
      "DataFine":this.end,
      "Indirizzo":this.address,
      "Stato":this.status,
      "Categoria":this.category,
      "color":this.color,
      "Responsabile":this.supervisor,
      "Operatore":this.operator,
      "SubOperatori":this.suboperators
  };

  Map<String, dynamic> toDocument(){
    return Map<String, dynamic>.of({
      "Titolo":this.title,
      "Descrizione":this.description,
      "DataInizio":this.start,
      "DataFine":this.end,
      "Indirizzo":this.address,
      "Documenti":this.documents,
      "Stato":this.status,
      "Categoria":this.category,
      "Responsabile":this.supervisor,
      "Operatore":this.operator,
      "SubOperatori":this.suboperators,
      "Motivazione" : this.motivazione,
    });
  }

  String get id => _id;
  String get title => _title;
  String get description => _description;
  DateTime get start => _start;
  DateTime get end => _end;
  String get address => _address;
  List<dynamic> get documents => _documents;
  int get status => _status;
  String get category => _category;
  String get color => _color;
  dynamic get supervisor => _supervisor;
  dynamic get operator => _operator;
  List<dynamic> get suboperators => _suboperators;
  String get motivazione => _motivazione;

  set id(String value) {
    _id = value;
  }

  set title(String value) {
    _title = value;
  }

  set description(String value) {
    _description = value;
  }

  set address(String value) {
    _address = value;
  }

  set documents(List<dynamic> value) {
    _documents = value;
  }

  set start(DateTime value) {
    _start = value;
  }

  set end(DateTime value) {
    _end = value;
  }

  set status(int value) {
    _status = value;
  }

  set category(String value) {
    _category = value;
  }

  set color(String value) {
    _color = value;
  }

  set supervisor(dynamic value) {
    _supervisor = value;
  }

  set operator(dynamic value) {
    _operator = value;
  }

  set suboperators(List<dynamic> value) {
    _suboperators = value;
  }

  set motivazione(String value){
    _motivazione = value;
  }

  bool isBetweenDate(DateTime dataInizio,DateTime dataFine){
    if(((this.start.isAfter(dataInizio) || this.start.isAtSameMomentAs(dataInizio)) && this.start.isBefore(dataFine)) || (this.end.isAfter(dataInizio) && (this.end.isBefore(dataFine)) || this.end.isAtSameMomentAs(dataFine)) || (this.start.isBefore(dataInizio) && this.end.isAfter(dataFine)) || (this.start.isAtSameMomentAs(dataInizio) && this.end.isAtSameMomentAs(dataFine))){
      return true;
    }else{
      return false;
    }
  }

  bool isAllDayLong() {
    final differenceInHour = this.end.difference(this.start).inHours;
    final dayDuration = Constants.MAX_WORKTIME - Constants.MIN_WORKTIME;
    if(differenceInHour >= dayDuration){
      return true;
    }
    return false;
  }

}

class Status {
  static const int Deleted = -1;
  static const int New = 0;
  static const int Delivered = 1;
  static const int Seen = 2;
  static const int Accepted = 3;
  static const int Refused = 4;
  static const int Ended = 5;

  static IconData getIcon(int status){
    switch(status){
      case Deleted:
        return Icons.delete;
      case  New:
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
    }
  }

  static String getText(int status){
    switch(status){
      case Status.Deleted: return "Eliminato";
      case Status.New: return "Nuovo";
      case Status.Delivered: return "Consegnato";
      case Status.Seen: return "Visualizzato";
      case Status.Accepted: return "Accettato";
      case Status.Refused: return "Rifiutato";
      case Status.Ended: return "Terminato";
    }
  }
}