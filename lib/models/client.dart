import 'package:venturiautospurghi/utils/extensions.dart';

class Client {
  String id = "";
  String name = "";
  String email = "";
  String phone = "";
  String partitaIva = "";
  String codFiscale = "";
  List<dynamic> address = [];
  bool company = false;

  Client(this.id,this.name,this.email,this.phone, this.partitaIva,this.codFiscale, this.company, this.address);
  Client.empty();

  Client.fromMap(String id, Map<String,dynamic> json) :
        id = !string.isNullOrEmpty(id)? id : json["Id"] ?? json["id"] ?? "",
        name = json['Nome'],
        email = json['Email'],
        phone = json['Telefono'],
        codFiscale = json['CodiceFiscale'],
        partitaIva = json['PartitaIva'],
        address = json['Indirizzi']??[],
        company = json['Company'];

  Map<String, dynamic> toMap() => {
    "id":this.id,
    "Nome":this.name,
    "Email":this.email,
    "Telefono":this.phone,
    "PartitaIva": this.partitaIva,
    "CodiceFiscale":this.codFiscale,
    "Indirizzi": this.address,
    "Company":this.company,
  };

  Map<String, dynamic> toDocument() {
    return Map<String, dynamic>.of({
      "Nome":this.name,
      "Email":this.email,
      "Telefono":this.phone,
      "PartitaIva": this.partitaIva,
      "CodiceFiscale":this.codFiscale,
      "Indirizzi": this.address,
      "Company":this.company,
    });
  }

  Map<String, dynamic> toWebDocument() {
    return Map<String, dynamic>.of({
      "Id":this.id,
      "Nome":this.name,
      "Email":this.email,
      "Telefono":this.phone,
      "PartitaIva": this.partitaIva,
      "CodiceFiscale":this.codFiscale,
      "Indirizzi": this.address,
      "Company":this.company,
    });
  }

  void update(Client clientUpdate) {
    this.name = clientUpdate.name;
    this.email = clientUpdate.email;
    this.phone = clientUpdate.phone;
    this.codFiscale = clientUpdate.codFiscale;
    this.company = clientUpdate.company;
    this.partitaIva = clientUpdate.partitaIva;
    this.address = clientUpdate.address;
  }

}