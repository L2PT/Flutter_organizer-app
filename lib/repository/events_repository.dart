// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;



class EventsRepository {
  final collectionEventi = PlatformUtils.fire.collection(global.Constants.tabellaEventi);
  final subCollectionStorico = PlatformUtils.fire.collectionGroup(global.Constants.subtabellaStorico);
  final collectionEliminati = PlatformUtils.fire.collection(global.Constants.tabellaEventiEliminati);
  final collectionTerminati = PlatformUtils.fire.collection(global.Constants.tabellaEventiTerminati);
  Map<String,dynamic> categories;
  Future init() async {
    categories = await Utils.getCategories();
    return;
  }

  Future<Event> getEvent(String id) async {
    var doc = await PlatformUtils.fireDocument(global.Constants.tabellaEventi, id).get();
    return Event.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), categories!=null?
    categories[doc["Categoria"]] != null
        ? categories[doc["Categoria"]]
        : categories['default']:global.Constants.fallbackHexColor, PlatformUtils.extractFieldFromDocument(null, doc));
  }

  Future<List<Event>> getEvents() async {
    var docs = await PlatformUtils.fireDocuments(global.Constants.tabellaEventi);
    List<Event> events = List();
    for(dynamic doc in docs){
      if(doc!=null){
        events.add(Event.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), categories!=null?
        categories[doc["Categoria"]] != null
            ? categories[doc["Categoria"]]
            : categories['default']:global.Constants.fallbackHexColor, PlatformUtils.extractFieldFromDocument(null, doc)));
      }
    }
    return events;
  }

  Stream<List<Event>> events() {
    return collectionEventi.snapshots().map((snapshot) {
      return PlatformUtils.documents(snapshot).map((doc) {
        return Event.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), categories!=null?
        categories[doc["Categoria"]] != null
            ? categories[doc["Categoria"]]
            : categories['default']:global.Constants.fallbackHexColor, PlatformUtils.extractFieldFromDocument(null, doc));})
          .toList();
    });
  }

  //Snapshot - Eventi di un determinato operatore
  Stream<List<Event>> eventsByOperator(String idOperator) {
    return collectionEventi.where("IdOperatori", arrayContains: idOperator).snapshots().map((snapshot) {
      return PlatformUtils.documents(snapshot).map((doc) {
        return Event.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), categories!=null?
        categories[doc["Categoria"]] != null
            ? categories[doc["Categoria"]]
            : categories['default']:global.Constants.fallbackHexColor, PlatformUtils.extractFieldFromDocument(null, doc));})
          .toList();
    });
  }

  //Snapshot - Eventi da accettati in su, di un determinato operatore
  Stream<List<Event>> eventsByOperatorAcceptedOrAbove(String idOperator) {
    return collectionEventi.where("IdOperatori", arrayContains: idOperator).where("Stato", isGreaterThanOrEqualTo: Status.Accepted).snapshots().map((snapshot) {
      return PlatformUtils.documents(snapshot).map((doc) {
        return Event.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), categories!=null?
        categories[doc["Categoria"]] != null
            ? categories[doc["Categoria"]]
            : categories['default']:global.Constants.fallbackHexColor, PlatformUtils.extractFieldFromDocument(null, doc));})
          .toList();
    });
  }

  //Snapshot per eventi in waitingevent
  Stream<List<Event>> eventsWaiting(String idOperator) {
    return collectionEventi.where("IdOperatore", isEqualTo: idOperator).where("Stato", isLessThanOrEqualTo: Status.Seen).snapshots().map((snapshot) {
      return PlatformUtils.documents(snapshot).map((doc) {
        return Event.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), categories!=null?
        categories[doc["Categoria"]] != null
            ? categories[doc["Categoria"]]
            : categories['default']:global.Constants.fallbackHexColor, PlatformUtils.extractFieldFromDocument(null, doc));})
          .toList();
    });
  }

  //Snapshot per eventi in history
  Stream<List<Event>> eventsHistory() {
    return subCollectionStorico.snapshots().map((snapshot) {
      return PlatformUtils.documents(snapshot).map((doc) {
        return Event.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), categories!=null?
        categories[doc["Categoria"]] != null
            ? categories[doc["Categoria"]]
            : categories['default']:global.Constants.fallbackHexColor, PlatformUtils.extractFieldFromDocument(null, doc));})
          .toList();
    });
  }

  Stream<List<Event>> eventsDeleted() {
    return collectionEliminati.snapshots().map((snapshot) {
      return PlatformUtils.documents(snapshot).map((doc) {
        return Event.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), categories!=null?
        categories[doc["Categoria"]] != null
            ? categories[doc["Categoria"]]
            : categories['default']:global.Constants.fallbackHexColor, PlatformUtils.extractFieldFromDocument(null, doc));})
          .toList();
    });
  }

  Stream<List<Event>> eventsEnded() {
    return collectionTerminati.snapshots().map((snapshot) {
      return PlatformUtils.documents(snapshot).map((doc) {
        return Event.fromMap(PlatformUtils.extractFieldFromDocument("id", doc), categories!=null?
        categories[doc["Categoria"]] != null
            ? categories[doc["Categoria"]]
            : categories['default']:global.Constants.fallbackHexColor, PlatformUtils.extractFieldFromDocument(null, doc));})
          .toList();
    });
  }

  void deleteEvent(Event e) async {
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = PlatformUtils.fireDocument(global.Constants.tabellaEventi, e.id);
      e.status = Status.Deleted;
      await tx.set(PlatformUtils.fireDocument(global.Constants.tabellaEventiEliminati, e.id), e.toDocument());
      await tx.delete(dc);
    };
    PlatformUtils.fire.runTransaction(createTransaction);
  }

  void endEvent(Event e) {
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = PlatformUtils.fireDocument(global.Constants.tabellaEventi, e.id);
      await tx.set(PlatformUtils.fireDocument(global.Constants.tabellaEventiTerminati, e.id), e.toDocument());
      await tx.update(dc, {global.Constants.tabellaEventi_stato:e.status});
    };
    PlatformUtils.fire.runTransaction(createTransaction);
  }

  void updateEvent(Event e, String field, dynamic data) async {
    if(field==null)
      PlatformUtils.updateDocument(global.Constants.tabellaEventi, e.id, data);
    else
      PlatformUtils.updateDocument(global.Constants.tabellaEventi, e.id, {field:data});
  }

  Future<dynamic> addEvent(Event e, dynamic data) async {
    var docRef = await collectionEventi.add(data);
    return docRef;
  }

  void refuseEvent(Event e) async {
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = PlatformUtils.fireDocument(global.Constants.tabellaEventi, e.id);
      await tx.set(PlatformUtils.fireDocument(global.Constants.tabellaEventiRifiutati, e.id), e.toDocument());
      await tx.delete(dc);
    };
    PlatformUtils.fire.runTransaction(createTransaction);
  }

}
