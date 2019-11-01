import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';

class Event {
  String _id="";
  String _title="";
  String _description="";
  DateTime _start=DateTime.now();
  DateTime _end=DateTime.now();
  String _address="";
  int _status= Status.New;
  String _category="";
  String _color="";
  String _idSupervisor = "";
  String _idOperator = "";
  String _motivazione = "";
  List<dynamic> _idOperators = new List();
  dynamic _supervisor = null;
  dynamic _operator = null;
  List<dynamic> _suboperators = new List();


  Event(this._id, this._title, this._description, this._start, this._end, this._address, this._status, this._category, this._color, this._idSupervisor, this._idOperator, this._idOperators, this._supervisor, this._operator, this._suboperators, this._motivazione);
  Event.empty();
  Event.fromMapWeb(String id, String color, dynamic json){
    _id = (id!=null && id!="")?id:(json.id!=null)?json.id:"";
    _title = json.Titolo;
    _description = json.Descrizione;
    _start = new DateTime.fromMillisecondsSinceEpoch(json.DataInizio.seconds*1000);
    _end = new DateTime.fromMillisecondsSinceEpoch(json.DataFine.seconds*1000);
    _address = json.Indirizzo;
    _status = json.Stato;
    _category = json.Categoria;
    _motivazione = json.Motivazione;
    _color = (color!=null && color!="")?color:(json.color!=null)?json.color:"";
    _idSupervisor = json.IdResponsabile;
    _idOperator = json.IdOperatore;
    _idOperators = json.IdOperatori;
    _supervisor = PlatformUtils.AccountFromMap("d", json.Responsabile).toDocument();
    _operator = PlatformUtils.AccountFromMap("d", json.Operatore).toDocument();
    _suboperators = json.SubOperatori.map((op)=>PlatformUtils.AccountFromMap("d", op).toDocument()).toList();
  }

  Event.fromMap(String id, String color, dynamic json){
    _id = (id!=null && id!="")?id:(json["id"]!=null)?json["id"]:"";
    _title = json["Titolo"];
    _description = json["Descrizione"];
    _start = json["DataInizio"] is DateTime?json["DataInizio"]:new DateTime.fromMillisecondsSinceEpoch(json["DataInizio"].seconds*1000);
    _end = json["DataFine"] is DateTime?json["DataFine"]:new DateTime.fromMillisecondsSinceEpoch(json["DataFine"].seconds*1000);
    _address = json["Indirizzo"];
    _status = json["Stato"];
    _category = json["Categoria"];
    _color = (color!=null && color!="")?color:(json["color"]!=null)?json["color"]:"";
    _idSupervisor = json["IdResponsabile"];
    _idOperator = json["IdOperatore"];
    _idOperators = json["IdOperatori"];
    _supervisor = json["Responsabile"];
    _operator = json["Operatore"];
    _suboperators = json["SubOperatori"];
    _motivazione = json["Motivazione"];

  }

//  Map<String, dynamic> toMap(){
//    return Map<String, dynamic>.of({
//      "id":this.id,
//      "Titolo":this.title,
//      "Descrizione":this.description,
//      "DataInizio":this.start,
//      "DataFine":this.end,
//      "Indirizzo":this.address,
//      "Stato":this.status,
//      "Categoria":this.category,
//      "color":this.color,
//      "Responsabile":this.supervisor,
//      "Operatore":this.operator,
//      "SubOperatori":this.suboperators
//    });
//  }

  Map<String, dynamic> toDocument(){
    return Map<String, dynamic>.of({
      "Titolo":this.title,
      "Descrizione":this.description,
      "DataInizio":this.start,
      "DataFine":this.end,
      "Indirizzo":this.address,
      "Stato":this.status,
      "Categoria":this.category,
      "IdResponsabile":this.idSupervisor,
      "IdOperatore":this.idOperator,
      "IdOperatori":this.idOperators,
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
  int get status => _status;
  String get category => _category;
  String get color => _color;
  String get idSupervisor => _idSupervisor;
  String get idOperator => _idOperator;
  List<dynamic> get idOperators => _idOperators;
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

  set idSupervisor(String value) {
    _idSupervisor = value;
  }

  set idOperator(String value) {
    _idOperator = value;
  }

  set idOperators(List<dynamic> value) {
    _idOperators = value;
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

}

class Status {
  static const int New = 0;
  static const int Delivered = 1;
  static const int Seen = 2;
  static const int Accepted = 3;
  static const int Rejected = 4;
}