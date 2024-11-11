import 'package:equatable/equatable.dart';

class Address extends Equatable{
  String address = "";
  String phone = "";

  Address(this.address,this.phone);
  Address.empty();

  Address.fromMap(Map<String,dynamic> json) :
        address = json['Indirizzo'],
        phone = json['Telefono'];

  Map<String, dynamic> toMap() => {
    "Indirizzo":this.address,
    "Telefono": this.phone,
  };

  Map<String, dynamic> toDocument() {
    return Map<String, dynamic>.of({
      "Indirizzo":this.address,
      "Telefono": this.phone,
    });
  }

  Map<String, dynamic> toWebDocument() {
    return Map<String, dynamic>.of({
      "Indirizzo":this.address,
      "Telefono": this.phone,
    });
  }

  void update(Address addressUpdate) {
    this.address = addressUpdate.address;
    this.phone = addressUpdate.phone;
  }

  @override
  List<Object?> get props => [address, phone];
}