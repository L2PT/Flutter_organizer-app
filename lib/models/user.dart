class Utente {
  String _id;
  String _codFiscale;
  String _cognome;
  String _email;
  String _nome;
  bool _occupato;
  bool _responsabile;
  String _telefono;

  Utente(this._id, this._codFiscale, this._cognome, this._email, this._nome, this._occupato, this._responsabile, this._telefono);

  String get id => _id;
  String get codFiscale => _codFiscale;
  String get cognome => _cognome;
  String get email => _email;
  String get nome => _nome;
  bool get occupato => _occupato;
  bool get responsabile => _responsabile;
  String get telefono => _telefono;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['CodiceFiscale'] = _codFiscale;
    map['Cognome'] = _cognome;
    map['Email'] = _email;
    map['Nome'] = _nome;
    map['Occupato'] = _occupato;
    map['Responsabile'] = _responsabile;
    map['Telefono'] = _telefono;

    return map;
  }

  Utente.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._codFiscale = map['CodiceFiscale'];
    this._cognome = map['Cognome'];
    this._email = map['Email'];
    this._nome = map['Nome'];
    this._occupato = map['Occupato'];
    this._responsabile = map['Responsabile'];
    this._telefono = map['Telefono'];
  }
}