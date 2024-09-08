import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/address.dart';
import 'package:venturiautospurghi/utils/extensions.dart';

class Customer extends Equatable{
  String id = "";
  String name = "";
  String surname = "";
  String email = "";
  String phone = "";
  Address address = Address.empty();
  List<dynamic> phones = [];
  String partitaIva = "";
  String codFiscale = "";
  List<Address> addresses = [];
  String typology = "Privato";

  Customer(this.id,this.name,this.surname,this.email,this.phone, this.phones, this.partitaIva,this.codFiscale, this.typology, this.address, this.addresses);
  Customer.empty();

  Customer.fromMap(String id, Map<String,dynamic> json) :
        id = !string.isNullOrEmpty(id)? id : json["Id"] ?? json["id"] ?? "",
        name = json['Nome'],
        surname = json['Cognome']??'',
        email = json['Email'],
        phone = json['Telefono'],
        phones = json['Telefoni'] != null?List.from(json['Telefoni']):[],
        codFiscale = json['CodiceFiscale']??'',
        partitaIva = json['PartitaIva'],
        addresses = (json["Indirizzi"] as List).map((address) => Address.fromMap(address)).toList(),
        address = json["Indirizzo"] == null? Address.empty(): Address.fromMap(json["Indirizzo"]),
        typology = json['Tipologia']??"Privato";

  Map<String, dynamic> toMap() => {
    "id":this.id,
    "Nome":this.name,
    "Cognome": this.surname,
    "Email":this.email,
    "Telefono":this.phone,
    "Telefoni":this.phones,
    "PartitaIva": this.partitaIva,
    "CodiceFiscale":this.codFiscale,
    "Indirizzi": this.addresses.map((address)=>address.toMap()).toList(),
    "Indirizzo": this.address.toMap(),
    "Tipologia":this.typology,
  };

  Map<String, dynamic> toDocument() {
    return Map<String, dynamic>.of({
      "Nome":this.name,
      "Cognome": this.surname,
      "Email":this.email,
      "Telefono":this.phone,
      "Telefoni":this.phones,
      "PartitaIva": this.partitaIva,
      "CodiceFiscale":this.codFiscale,
      "Indirizzi": this.addresses.map((address)=>address.toMap()).toList(),
      "Indirizzo": this.address.toMap(),
      "Tipologia":this.typology,
    });
  }

  Map<String, dynamic> toWebDocument() {
    return Map<String, dynamic>.of({
      "Id":this.id,
      "Nome":this.name,
      "Cognome": this.surname,
      "Email":this.email,
      "Telefono":this.phone,
      "Telefoni":this.phones,
      "PartitaIva": this.partitaIva,
      "CodiceFiscale":this.codFiscale,
      "Indirizzi": this.addresses,
      "Indirizzo": this.address,
      "Tipologia":this.typology,
    });
  }

  void update(Customer clientUpdate) {
    this.name = clientUpdate.name;
    this.surname = clientUpdate.surname;
    this.email = clientUpdate.email;
    this.phones = clientUpdate.phones;
    this.phone = clientUpdate.phone;
    this.codFiscale = clientUpdate.codFiscale;
    this.typology = clientUpdate.typology;
    this.partitaIva = clientUpdate.partitaIva;
    this.addresses = clientUpdate.addresses;
    this.address = clientUpdate.address;
  }

  bool isCompany(){
    return this.typology == "Azienda";
  }

  bool filter(lambda, value){
    return lambda(this, value);
  }

  @override
  String toString() => id+name+surname+email+phones.join()+phone.toString()+partitaIva+codFiscale+typology+typology+address.toString()+addresses.join();

  @override
  List<Object?> get props => [name, surname, email, phone, address, addresses, phones, partitaIva, codFiscale, typology];

}