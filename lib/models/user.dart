class Account {
  String _id="";
  String _name="";
  String _surname="";
  String _email="";
  String _phone="";
  String _codFiscale="";
  List<dynamic> _webops = new List();
  String _token="";
  bool _supervisor=false;

  Account(this._id, this._name, this._surname, this._email, this._phone, this._codFiscale, this._webops, this._token, this._supervisor);
  Account.empty();
  Account.fromMapWeb(String id, dynamic json) {
    _id = (id!=null && id!="")?id:(json.id!=null)?json.id:"";
    _name = json.Nome;
    _surname = json.Cognome;
    _email = json.Email;
    _phone = json.Telefono;
    _codFiscale = json.CodiceFiscale;
    _webops = json.OperatoriWeb;
    _token = json.Token;
    _supervisor = json.Responsabile;
  }

  Account.fromMap(String id, dynamic json) {
    _id = (id!=null && id!="")?id:(json["id"]!=null)?json["id"]:"";
    _name = json['Nome'];
    _surname = json['Cognome'];
    _email = json['Email'];
    _phone = json['Telefono'];
    _codFiscale = json['CodiceFiscale'];
    _webops = json['OperatoriWeb'];
    _token = json['Token'];
    _supervisor = json['Responsabile'];
  }

  Map<String, dynamic> toMap() {
    return Map<String, dynamic>.of({
      "id":this.id,
      "Nome":this.name,
      "Cognome":this.surname,
      "Email":this.email,
      "Telefono":this.phone,
      "CodiceFiscale":this.codFiscale,
      "Token":this.token,
      "Responsabile":this.supervisor
    });
  }

  Map<String, dynamic> toDocument() {
    return Map<String, dynamic>.of({
      "Nome":this.name,
      "Cognome":this.surname,
      "Email":this.email,
      "Telefono":this.phone,
      "OperatoriWeb":this.webops,
      "Token":this.token,
      "CodiceFiscale":this.codFiscale,
      "Responsabile":this.supervisor
    });
  }

  String get id => _id;
  String get name => _name;
  String get surname => _surname;
  String get email => _email;
  String get phone => _phone;
  String get codFiscale => _codFiscale;
  List<dynamic> get webops => _webops;
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

  set webops(List<dynamic> value) {
    _webops = value;
  }

}
