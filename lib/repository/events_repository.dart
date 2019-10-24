// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';


class EventsRepository {
  final collection = PlatformUtils.fire.collection('Eventi');
  Map<String,dynamic> categories;
  Future init() async {
    categories = await Utils.getCategories();
    return;
  }

  //TODO TURRO
  //Snapshot per eventi in dailycalendar, quindi dato un operatore prendi gli eventi di tutte le date(gli stati non lo so, se da operatore a responsabile cambia qualcosa fai due snapshot diverse eventualmente)
  //Snapshot per eventi in waitingevent
  //Snapshot per eventi eliminati(?sono due sezioni diverse questa e quella sotto?)
  //Snapshot per eventi terminati(?sono due sezioni diverse questa e quella sopra?)
  //Query per eliminare un evento, quindi cambiargli stato oppure spostarlo di collection non lo so
  //Query per terminare un evento, quindi cambiargli stato oppure spostarlo di collection non lo so
  //Query per cambiare lo stato dell'evento, per accettato e rifiutato (forse una singola dove ri-setti l'intero evento può andare)

  //Questa va bene
  @override
  Future<List<Event>> getEvents(DateTime selectedDay) async {
    var docs = await collection.where("days",isGreaterThanOrEqualTo:new DateTime.now().day).getDocuments();
    List a = docs.documents.map((doc) => PlatformUtils.EventFromMap(doc.documentID, categories[doc["Categoria"]]??categories['default'],doc))
          .toList();
    print(a.length);
    return a;
  }
  
  @override
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

  @override
  Stream<List<Event>> eventsWating() {
    return collection.snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) => PlatformUtils.EventFromMap(doc.documentID, categories[doc["Categoria"]]!=null?categories[doc["Categoria"]]:categories['default'],doc))
          .toList();
    });
  }
}
