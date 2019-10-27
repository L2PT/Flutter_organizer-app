// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;


class OperatorsRepository {
  final collection = PlatformUtils.fire.collection(global.Constants.tabellaUtenti);
  final EventsRepository eventsRepository = EventsRepository();
  Map<String,dynamic> categories;


  @override
  Future<List<Account>> getOperatorsFree(DateTime dataInizio, DateTime dataFine) async {
    var docs = await collection.getDocuments();
    List a = docs.documents.map((doc) => Account.fromMap(doc.documentID, doc)).toList();
    final List<Event> listEvent = await eventsRepository.getEvents();
    listEvent.forEach((event) {
      if (event.isBetweenDate(dataInizio, dataFine) != null) {
        event.idOperators.forEach((operator) {
          bool checkDelete = false;
          for (int i = 0; i < a.length && !checkDelete; i++) {
            if (a.elementAt(i).id = operator) {
              checkDelete = true;
              a.remove(i);
            }
          }
        });
      }
    });
    return a.toList();
  }

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
