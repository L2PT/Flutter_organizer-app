// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;



class EventsRepository {
  final collectionEventi = PlatformUtils.fire.collection('Eventi');
  final collectionEliminati = PlatformUtils.fire.collection("EventiEliminati");
  final collectionTerminati = PlatformUtils.fire.collection("EventiTermitati");
  Map<String,dynamic> categories;
  Future init() async {
    categories = await Utils.getCategories();
    return;
  }

  Future<List<Event>> getEvents() async {
    var docs = await collectionEventi.getDocuments();
    List a = docs.documents.map((doc) => PlatformUtils.EventFromMap(PlatformUtils.extractFieldFromDocument("id", doc),categories!=null?
        categories[doc["Categoria"]] != null
        ? categories[doc["Categoria"]]
        : categories['default']:global.Constants.fallbackHexColor,doc))
        .toList();
    return a;
  }

  Stream<List<Event>> events() {
    return collectionEventi.snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) {
        return PlatformUtils.EventFromMap(doc.documentID,
            categories[doc["Categoria"]] != null
                ? categories[doc["Categoria"]]
                : categories['default'], doc);
      })
          .toList();
    });
  }

  //Snapshot - Eventi di un determinato operatore
  Stream<List<Event>> eventsOperator(String idOperator) {
    return collectionEventi.where("IdOperatori", arrayContains: idOperator).snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) {
        return PlatformUtils.EventFromMap(doc.documentID,
            categories[doc["Categoria"]] != null
                ? categories[doc["Categoria"]]
                : categories['default'], doc);
      })
          .toList();
    });
    
  }

  //Snapshot per eventi in waitingevent
  Stream<List<Event>> eventsWaitingOpe(String idOperator) {
    return collectionEventi.where("IdOperatori", arrayContains: idOperator).where("Stato", isLessThan: Status.Accepted).snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) {
        return PlatformUtils.EventFromMap(doc.documentID,
            categories[doc["Categoria"]] != null
                ? categories[doc["Categoria"]]
                : categories['default'], doc);
      })
          .toList();
    });
  }

  Stream<List<Event>> eventsDeleted() {
    return collectionEliminati.snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) {
        return PlatformUtils.EventFromMap(doc.documentID,
            categories[doc["Categoria"]] != null
                ? categories[doc["Categoria"]]
                : categories['default'], doc);
      })
          .toList();
    });
  }

  Stream<List<Event>> eventsEnded() {
    return collectionTerminati.snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) {
        return PlatformUtils.EventFromMap(doc.documentID,
            categories[doc["Categoria"]] != null
                ? categories[doc["Categoria"]]
                : categories['default'], doc);
      })
          .toList();
    });
  }

  void deleteEvent(Event e) {//TODO to web
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = collectionEventi.document(e.id);
      await tx.set(collectionEliminati.document(e.id), e.toDocument());
      await tx.delete(dc);
    };
    PlatformUtils.fire.runTransaction(createTransaction);
  }

  void endEvent(Event e) {
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = collectionEventi.document(e.id);
      await tx.set(collectionTerminati.document(e.id), e.toDocument());
      await tx.delete(dc);
    };
    PlatformUtils.fire.runTransaction(createTransaction);
  }

  void updateEvent(Event e, String field, dynamic data){
      collectionEventi.document(e.id).updateData(e.toDocument());
  }

}
