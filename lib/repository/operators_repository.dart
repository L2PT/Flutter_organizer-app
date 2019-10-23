// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';

class OperatorsRepository {
  final collection = PlatformUtils.fire.collection('Utenti');
  Map<String,dynamic> categories;

  //TODO TURRO
  //Snapshot per prendere tutti gli operatori
  //Query per prendere tutti gli operatori
  //Query per prendere gli operatori liberi dato un intervallo di tempo, DataInizio DataFine (per operatori liberi devi controllare gli eventi. Gli eventi non ce li hai in input quindi li prendi da Firestore)

  //Questa va bene
  @override
  Future<void> addNewOperator(Account u) {
    return collection.add(u.toDocument());
  }

//  @override
//  Future<List<Account>> getOperators() async {
//    var docs = await collection.getDocuments();
//    List a = docs.documents.map((doc) => Account.fromMap(doc.documentID, doc)).toList();
//    return a;
//  }
//
//  @override
//  Future<List<Account>> getOperatorsFiltered() async {
//    var docs = await collection.getDocuments();
//    List a = docs.documents.map((doc) => Account.fromMap(doc.documentID, doc)).toList();
//    return a;
//  }

}
