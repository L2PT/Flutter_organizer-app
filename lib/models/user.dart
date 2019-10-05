class Utente {
  String _id;
  String _nome;
  String _cognome;
  String _email;
  String _telefono;
  String _codFiscale;
  bool _occupato;
  bool _responsabile;

  Utente(this._id, this._nome, this._cognome, this._email, this._telefono, this._codFiscale, this._occupato, this._responsabile);

  String get id => _id;
  String get nome => _nome;
  String get cognome => _cognome;
  String get email => _email;
  String get telefono => _telefono;
  String get codFiscale => _codFiscale;
  bool get occupato => _occupato;
  bool get responsabile => _responsabile;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['Nome'] = _nome;
    map['Cognome'] = _cognome;
    map['Email'] = _email;
    map['Telefono'] = _telefono;
    map['CodiceFiscale'] = _codFiscale;
    map['Occupato'] = _occupato;
    map['Responsabile'] = _responsabile;
    return map;
  }

  Utente.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._nome = map['Nome'];
    this._cognome = map['Cognome'];
    this._email = map['Email'];
    this._telefono = map['Telefono'];
    this._codFiscale = map['CodiceFiscale'];
    this._occupato = map['Occupato'];
    this._responsabile = map['Responsabile'];
  }
}