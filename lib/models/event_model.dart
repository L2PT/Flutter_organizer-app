
class Event {
  String title="";
  String description="";
  DateTime start=null;
  DateTime end=null;
  String address="";
  bool _seen=false;
  bool _accepted=false;
  bool _ended=false;
  String category="";
  String color="";

  Event(this.title, this.description, this.start, this.end, this.address, this.category);
  Event.fromJson(dynamic json)
      : title = json.Titolo,
        description = json.Descrizione,
        start = new DateTime.fromMillisecondsSinceEpoch(json.DataInizio.seconds*1000),
        end = new DateTime.fromMillisecondsSinceEpoch(json.DataFine.seconds*1000),
        _seen = json.Visualizzato,
        _accepted = json.Accettato,
        _ended = json._ended,
        category = json.Categoria,
        color = json.color;



  void seenTrue() {
    _seen = true;
    _accepted = false;
    _ended = false;
  }

  void acceptedTrue() {
    _seen = false;
    _accepted = true;
    _ended = false;
  }

  void endedTrue() {
    _seen = false;
    _accepted = false;
    _ended = true;
  }

}