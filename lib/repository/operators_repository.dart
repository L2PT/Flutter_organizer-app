// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;


class OperatorsRepository {
  final collectionUtenti = PlatformUtils.fire.collection(global.Constants.tabellaUtenti);

  Future<List<Account>> getOperatorsFree(String eventIdToIgnore, DateTime dataInizio, DateTime dataFine) async {
    var docs = await PlatformUtils.fireDocuments(global.Constants.tabellaUtenti);
    //la versione breve cioè map(()=> ).toList() non funziona per problemi di casting dynamic to Account
    List<Account> accounts = List();
    for(dynamic doc in docs){
      if(doc!=null){
        accounts.add(Account.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), PlatformUtils.extractFieldFromDocument(null, doc)));
      }
    }
    final List<Event> listEvent = await EventsRepository().getEvents();
    listEvent.forEach((event) {
      if (event.id != eventIdToIgnore) {
        if (event.isBetweenDate(dataInizio, dataFine)) {
          event.idOperators.forEach((idOperator) {
            bool checkDelete = false;
            for (int i = 0; i < accounts.length && !checkDelete; i++) {
              if (accounts
                  .elementAt(i)
                  .id == idOperator) {
                checkDelete = true;
                accounts.removeAt(i);
              }
            }
          });
        }
      }
    });
    return accounts;
  }

  Future<List<Account>> getOperators() async {
    var docs = await PlatformUtils.fireDocuments(global.Constants.tabellaUtenti);
    List<Account> accounts = List();
    for(dynamic doc in docs){
      if(doc!=null){
        accounts.add(Account.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), PlatformUtils.extractFieldFromDocument(null, doc)));
      }
    }
    return accounts;
  }

  void addOperator(Account u) {
    PlatformUtils.setDocument(global.Constants.tabellaUtenti, u.id, u.toDocument());
  }

  void updateOperator(String doc, String field, dynamic data) {
    PlatformUtils.fireDocument(global.Constants.tabellaUtenti,doc).update(data:Map.of({field:data}));
  }

  void deleteOperator(String doc) {
    PlatformUtils.fireDocument(global.Constants.tabellaUtenti,doc).delete();
  }

}
