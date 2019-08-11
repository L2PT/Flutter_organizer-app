
class Event {
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String address;
  bool _seen=false;
  bool _accepted=false;
  bool _ended=false;
  String category;

  Event(this.title, this.description, this.start, this.end, this.address, this.category);

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