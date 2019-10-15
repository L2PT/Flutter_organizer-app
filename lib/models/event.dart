
class Event {
  String _id="";
  String _title="";
  String _description="";
  DateTime _start=DateTime.now();
  DateTime _end=DateTime.now();
  String _address="";
  int _status=Status.New;
  String _category="";
  String _color="";
  String _op="";
  List<dynamic> _subops = new List();

  Event(this._id, this._title, this._description, this._start, this._end, this._address, this._status, this._category, this._color, this._op, this._subops);
  Event.empty();
  Event.fromMap(String id, String color, dynamic json){
    _id = (id!=null && id!="")?id:(json["id"]!=null)?json["id"]:"";
    _title = json["Titolo"];
    _description = json["Descrizione"];
    _start = new DateTime.fromMillisecondsSinceEpoch(json["DataInizio"].seconds*1000);
    _end = new DateTime.fromMillisecondsSinceEpoch(json["DataFine"].seconds*1000);
    _address = json["Indirizzo"];
    _status = json["Stato"];
    _category = json["Categoria"];
    _color = (color!=null && color!="")?color:(json["color"]!=null)?json["color"]:"";
    _op = json["Operatore"];
    _subops = json["SubOperatori"];
  }

  Map<String, dynamic> toMap(){
    return Map<String, dynamic>.of({
      "id":this.id,
      "Titolo":this.title,
      "Descrizione":this.description,
      "DataInizio":this.start,
      "DataFine":this.end,
      "Indirizzo":this.address,
      "Stato":this.status,
      "Categoria":this.category,
      "color":this.color,
      "Operatore":this.op,
      "SubOperatori":this.subops
    });
  }

  Map<String, dynamic> toDocument(){
    return Map<String, dynamic>.of({
      "Titolo":this.title,
      "Descrizione":this.description,
      "DataInizio":this.start,
      "DataFine":this.end,
      "Indirizzo":this.address,
      "Stato":this.status,
      "Categoria":this.category,
      "Operatore":this.op,
      "SubOperatori":this.subops
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
  String get op => _op;
  List<String> get subops => _subops;

  set color(String value) {
    _color = value;
  }

  set category(String value) {
    _category = value;
  }

  set status(int value) {
    _status = value;
  }

  set address(String value) {
    _address = value;
  }

  set end(DateTime value) {
    _end = value;
  }

  set start(DateTime value) {
    _start = value;
  }

  set description(String value) {
    _description = value;
  }

  set title(String value) {
    _title = value;
  }

  set id(String value) {
    _id = value;
  }

  set subops(List<String> value) {
    _subops = value;
  }

  set op(String value) {
    _op = value;
  }

}

class Status {
  static const int New = 0;
  static const int Delivered = 1;
  static const int Seen = 2;
  static const int Accepted = 3;
  static const int Rejected = 4;
  static const int Ended = 5;
}