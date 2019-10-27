// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';


class EventsRepository {
  final collection = Firestore.instance.collection('Eventi');
  final collectionEliminati = Firestore.instance.collection("EventiEliminati");
  final collectionTerminati = Firestore.instance.collection("EventiTermitati");
  Map<String,dynamic> categories;
  Future init() async {
    categories = await Utils.getCategories();
    return;
  }

  //Questa va bene
  Future<List<Event>> getEventsDay(DateTime selectedDay) async {
    var docs = await collection.where("days",isGreaterThanOrEqualTo:new DateTime.now().day).getDocuments();
    List a = docs.documents.map((doc) => PlatformUtils.EventFromMap(doc.documentID, categories[doc["Categoria"]]??categories['default'],doc))
          .toList();
    print(a.length);
    return a;
  }
  
  Future<List<Event>> getEvents() async {
   var docs = await collection.getDocuments();
    List a = docs.documents.map((doc) => PlatformUtils.EventFromMap(doc.documentID, categories[doc["Categoria"]]??categories['default'],doc))
        .toList();
    return a;
  }

  Stream<List<Event>> events() {
    return collection.snapshots().map((snapshot) {
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
    return collection.where("IdOperatori", arrayContains: idOperator).snapshots().map((snapshot) {
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
  Stream<List<Event>> eventsWatingOpe(String idOperator) {
    return collection.where("IdOperatori", arrayContains: idOperator).where("Stato", isLessThan: Status.Accepted).snapshots().map((snapshot) {
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

  Stream<List<Event>> eventsDelete() {
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

  Stream<List<Event>> eventsTerminati() {
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

  void deleteEvent(Event e) async*{
    final TransactionHandler createTransaction = (Transaction tx) async {
      DocumentReference dc = collection.document(e.id);
      await tx.set(collectionEliminati.document(e.id), e.toDocument());
      await tx.delete(dc);
    };
    Firestore.instance.runTransaction(createTransaction);
  }

  void endedEvent(Event e) {
    final TransactionHandler createTransaction = (Transaction tx) async {
      DocumentReference dc = collection.document(e.id);
      await tx.set(collectionTerminati.document(e.id), e.toDocument());
      await tx.delete(dc);
    };
    Firestore.instance.runTransaction(createTransaction);
  }

  void updateEvent(Event e, String field, dynamic data){
      collection.document(e.id).updateData(e.toDocument());
  }

}
