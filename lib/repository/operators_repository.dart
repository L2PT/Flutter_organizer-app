// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;


class OperatorsRepository {
  final collection = PlatformUtils.fire.collection(global.Constants.tabellaUtenti);
  Map<String,dynamic> categories;

  //TODO TURRO
  //Query per prendere gli operatori liberi dato un intervallo di tempo, DataInizio DataFine (per operatori liberi devi controllare gli eventi. Gli eventi non ce li hai in input quindi li prendi da Firestore)

  @override
  Future<List<Account>> getOperators() async {
    var docs = await collection.getDocuments();
    List a = docs.documents.map((doc) => Account.fromMap(doc.documentID, doc)).toList();
    return a;
  }

  @override
  Future<List<Account>> getOperatorsFiltered() async {
    var docs = await PlatformUtils.waitFireCollection(global.Constants.tabellaUtenti);
    //la versione breve cioè map(()=> ).toList() non funziona sul web
    List<Account> b = [];
    for(dynamic a in docs){
      if(a!=null){
        b.add(Account.fromMap(PlatformUtils.extractFieldFromDocument("id", a), PlatformUtils.extractFieldFromDocument(null, a)));
      }
    }
    return b;
  }

  @override
  void addOperator(Account u) {
    PlatformUtils.setDocument(global.Constants.tabellaUtenti, u.id, u.toDocument());
  }

  @override
  void updateOperator(String doc, String field, dynamic data) {
    PlatformUtils.fireDocument(global.Constants.tabellaUtenti,doc).update(data:Map.of({field:data}));
  }

  @override
  void deleteOperator(String doc) {
    PlatformUtils.fireDocument(global.Constants.tabellaUtenti,doc).delete();
  }



}
