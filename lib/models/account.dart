import 'package:venturiautospurghi/utils/extensions.dart';

class Account {
  String _id="";
  String _name="";
  String _surname="";
  String _email="";
  String _phone="";
  String _codFiscale="";
  List<Account> _webops = new List();
  String _token="";
  bool _supervisor=false;

  Account(this._id, this._name, this._surname, this._email, this._phone, this._codFiscale, this._webops, this._token, this._supervisor);
  Account.empty();
  Account.fromMapWeb(String id, dynamic json) {
    // _id = (id!=null && id!="")?id:(json.id!=null)?json.id:"";
    // _name = json.Nome;
    // _surname = json.Cognome;
    // _email = json.Email;
    // _phone = json.Telefono;
    // _codFiscale = json.CodiceFiscale;
    // _webops = json.OperatoriWeb;
    // _token = json.Token;
    // _supervisor = json.Responsabile;
  }

  Account.fromMap(String id, Map<String,dynamic> json) :
    _id = !id.isNullOrEmpty()? id : json["Id"] ?? "",
    _name = json['Nome'],
    _surname = json['Cognome'],
    _email = json['Email'],
    _phone = json['Telefono'],
    _codFiscale = json['CodiceFiscale'],
    _webops = json.containsKey('OperatoriWeb')?dynamicToObject(json['OperatoriWeb']):List<Account>(),
    _token = json['Token'],
    _supervisor = json['Responsabile'];

  Map<String, dynamic> toMap() => {
      "id":this.id,
      "Nome":this.name,
      "Cognome":this.surname,
      "Email":this.email,
      "Telefono":this.phone,
      "CodiceFiscale":this.codFiscale,
      "Token":this.token,
      "Responsabile":this.supervisor
  };

  Map<String, dynamic> toDocument() {
    return Map<String, dynamic>.of({
      "Nome":this.name,
      "Cognome":this.surname,
      "Email":this.email,
      "Telefono":this.phone,
      "CodiceFiscale":this.codFiscale,
      "Token":this.token,
      "Responsabile":this.supervisor,
      "OperatoriWeb":this.webops,
    });
  }

  Map<String, dynamic> toWebOpDocument() {
    return Map<String, dynamic>.of({
      "Id":this.id,
      "Nome":this.name,
      "Cognome":this.surname,
      "Email":this.email,
      "Telefono":this.phone,
      "CodiceFiscale":this.codFiscale,
      "Token":this.token,
      "Responsabile":this.supervisor,
    });
  }

  String get id => _id;
  String get name => _name;
  String get surname => _surname;
  String get email => _email;
  String get phone => _phone;
  String get codFiscale => _codFiscale;
  List<Account> get webops => _webops;
  String get token => _token;
  bool get supervisor => _supervisor;

  set supervisor(bool value) {
    _supervisor = value;
  }

  set codFiscale(String value) {
    _codFiscale = value;
  }

  set phone(String value) {
    _phone = value;
  }

  set email(String value) {
    _email = value;
  }

  set surname(String value) {
    _surname = value;
  }

  set name(String value) {
    _name = value;
  }

  set id(String value) {
    _id = value;
  }

  set token(String value) {
    _token = value;
  }

  set webops(List<Account> value) {
    _webops = value;
  }

  void update(Account userUpdate) {
    this.name = userUpdate.name;
    this.surname = userUpdate.surname;
    this.email = userUpdate.email;
    this.phone = userUpdate.phone;
    this.codFiscale = userUpdate.codFiscale;
    this.webops = userUpdate.webops;
    this.token = userUpdate.token;
    this.supervisor = userUpdate.supervisor;
  }

  static List<Account> dynamicToObject(List<dynamic> json){
    List<Account> els = [];
    json.forEach((webOp)=>els.add(Account.fromMap("", webOp)));
    return els;
  }

}
