import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/customer.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

class Event {
  String id = "";
  String title = "";
  String description = "";
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  String address = "";
  List<dynamic> documents = [];
  int status = EventStatus.New;
  String category = "";
  String color = "";
  String motivazione = "";
  Account? supervisor;
  Customer customer = Customer.empty();
  Account? operator;
  List<Account> suboperators = [];


  Event(this.id, this.title, this.description, this.start, this.end, this.address, this.documents, this.status, this.category, this.color, this.supervisor, this.operator, this.suboperators, this.motivazione, this.customer);
  Event.empty();

  Event.fromMap(String id, String color, Map json) :
    id = (id!=null && id!="")?id:(json["id"]!=null)?json["id"]:"",
    title = json["Titolo"],
    description = json["Descrizione"],
    start = json["DataInizio"] is DateTime?json["DataInizio"]:DateTime.fromMillisecondsSinceEpoch(json["DataInizio"].seconds*1000).toLocal(),
    end = json["DataFine"] is DateTime?json["DataFine"]:DateTime.fromMillisecondsSinceEpoch(json["DataFine"].seconds*1000).toLocal(),
    address = json["Indirizzo"],
    documents = json["Documenti"]??[],
    status = json["Stato"],
    category = json["Categoria"],
    color = (!string.isNullOrEmpty(color))?color:json["color"]??"",
    supervisor = json["Responsabile"]==null?Account.empty():Account.fromMap("", json["Responsabile"]),
    operator = json["Operatore"]==null?Account.empty():Account.fromMap("", json["Operatore"]),
    suboperators = (json["SubOperatori"] as List).map((subOp) => Account.fromMap("", subOp)).toList(),
    motivazione = json["Motivazione"]??"",
    customer = json["Cliente"] == null? Customer.empty(): Customer.fromMap(id, json["Cliente"]);

  Map<String, dynamic> toMap() => {
      "id":this.id,
      "Titolo":this.title,
      "Descrizione":this.description,
      "DataInizio":this.start,
      "DataFine":this.end,
      "Indirizzo":this.address,
      "Documenti":this.documents,
      "Stato":this.status,
      "Categoria":this.category,
      "color":this.color,
      "Responsabile":this.supervisor?.toMap(),
      "Cliente": this.customer.toMap(),
      "Operatore":this.operator?.toMap(),
      "SubOperatori":this.suboperators.map((op)=>op.toMap()).toList()
  };
  Map<String, dynamic> toDocument(){
    return Map<String, dynamic>.of({
      "Titolo":this.title,
      "Descrizione":this.description,
      "DataInizio":this.start.toUtc(),
      "DataFine":this.end.toUtc(),
      "Indirizzo":this.address,
      "Documenti":this.documents,
      "Stato":this.status,
      "Categoria":this.category,
      "Responsabile":this.supervisor?.toMap(),
      "Cliente": this.customer.toMap(),
      "Operatore":this.operator?.toMap(),
      "SubOperatori": this.suboperators.map((op)=>op.toMap()).toList(),
      "Motivazione" : this.motivazione,
      "IdOperatore" : this.operator?.id??"",
      "IdOperatori" : [...this.suboperators.map((op) => op.id),operator?.id??""],
    });
  }

  bool isBetweenDate(DateTime dataInizio,DateTime dataFine){
    if(((this.start.isAfter(dataInizio) || this.start.isAtSameMomentAs(dataInizio)) && this.start.isBefore(dataFine)) || (this.end.isAfter(dataInizio) && (this.end.isBefore(dataFine)) || this.end.isAtSameMomentAs(dataFine)) || (this.start.isBefore(dataInizio) && this.end.isAfter(dataFine)) || (this.start.isAtSameMomentAs(dataInizio) && this.end.isAtSameMomentAs(dataFine))){
      return true;
    }else{
      return false;
    }
  }

  bool filter(lambda, value){
    return lambda(this, value);
  }

  bool isAllDayLong() {
    final differenceInHour = this.end.difference(this.start).inHours;
    final dayDuration = Constants.MAX_WORKTIME - Constants.MIN_WORKTIME;
    return differenceInHour >= dayDuration;
  }
  bool isDeleted() => this.status == EventStatus.Deleted;
  bool isNew() => this.status == EventStatus.New;
  bool isDelivered() => this.status == EventStatus.Delivered;
  bool isSeen() => this.status == EventStatus.Seen;
  bool isAccepted() => this.status == EventStatus.Accepted;
  bool isRefused() => this.status == EventStatus.Refused;
  bool isEnded() => this.status == EventStatus.Ended;

  @override
  String toString() => id+title+description+documents.join()+start.toString()+end.toString()+address+(status).toString()+category+color+(operator?.id??"")+suboperators.map((o) => o.id).join()+(motivazione);

}