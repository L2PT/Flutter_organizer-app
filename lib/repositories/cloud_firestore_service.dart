import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/utils/date_utils.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

class CloudFirestoreService {

  final FirebaseFirestore _cloudFirestore;
  late CollectionReference _collectionUtenti;
  late CollectionReference _collectionEventi;
  late Query _collectionSubStoricoEventi;
  late CollectionReference _collectionStoricoEliminati;
  late CollectionReference _collectionStoricoTerminati;
  late CollectionReference _collectionStoricoRifiutati;
  late CollectionReference _collectionCostanti;

  late Map<String,dynamic> categories;

  CloudFirestoreService([FirebaseFirestore? cloudFirestore])
      : _cloudFirestore = cloudFirestore ??  FirebaseFirestore.instance {
    _collectionUtenti = _cloudFirestore.collection(Constants.tabellaUtenti) ;
    _collectionEventi = _cloudFirestore.collection(Constants.tabellaEventi);
    _collectionSubStoricoEventi = _cloudFirestore.collectionGroup(Constants.subtabellaStorico);
    _collectionStoricoEliminati = _cloudFirestore.collection(Constants.tabellaEventiEliminati);
    _collectionStoricoTerminati = _cloudFirestore.collection(Constants.tabellaEventiTerminati);
    _collectionStoricoRifiutati = _cloudFirestore.collection(Constants.tabellaEventiRifiutati);
    _collectionCostanti = _cloudFirestore.collection(Constants.tabellaCostanti);
  }

  static Future<CloudFirestoreService> create() async {
    CloudFirestoreService instance = CloudFirestoreService();
    instance.categories = await instance._getCategories();
    return instance;
  }

  /// Function to retrieve from the database the information associated with the
  /// user logged in. The Firebase AuthUser uid must be the same as the id of the
  /// document in the "Utenti" [Constants.tabellaUtenti] collection.
  /// However the mail is also an unique field.
  Future<Account> getAccount(String email, {String? phoneId}) async {
    if(!string.isNullOrEmpty(email))
      return _collectionUtenti.where('Email', isEqualTo: email).get().then((snapshot) => snapshot.docs.map((document) => Account.fromMap(document.id, document.data()!)).first);
    else
      return _collectionUtenti.where('TelefonoId', isEqualTo: phoneId??"").get().then((snapshot) => snapshot.docs.map((document) => Account.fromMap(document.id, document.data()!)).first);
  }

  Stream<Account> subscribeAccount(String id)  {
    return _collectionUtenti.doc(id).snapshots().map((user) {
      return Account.fromMap(user.id, user.data()!);
    });
  }

  Future<List<Account>> getOperatorsFree(String eventIdToIgnore, DateTime startFrom, DateTime endTo) async {
    List<Account> accounts = await this.getOperators();

    final List<Event> listEvents = await this.getEvents();
    if(Constants.debug) listEvents.removeWhere((event) => event.status == EventStatus.Refused || event.status == EventStatus.Deleted); //TODO lasciamolo per un po'
    listEvents.forEach((event) {
      if (event.id != eventIdToIgnore) {
        if (event.isBetweenDate(startFrom, endTo)) {
          [event.operator, ...event.suboperators].map((e) => e!.id).forEach((idOperator) {
            bool checkDelete = false;
            for (int i = 0; i < accounts.length && !checkDelete; i++) {
              if (accounts.elementAt(i).id == idOperator) {
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
    return _collectionUtenti.get().then((snapshot) => snapshot.docs.map((document) => Account.fromMap(document.id, document.data()!)).toList());
  }

  void addOperator(Account u) {
    _collectionUtenti.doc(u.id).set(u.toDocument());
  }

  void deleteOperator(String id) {
    _collectionUtenti.doc(id).delete();
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<Map<String, dynamic>> _getCategories() async {
    return _collectionCostanti.doc(Constants.tabellaCostanti_Categorie).get().then((document) => document.data()!);
  }

  Future<Map<String, dynamic>> getPhoneNumbers() async {
    return _collectionCostanti.doc(Constants.tabellaCostanti_Telefoni).get().then((document) => document.data()!);
  }

  Future<Event?> getEvent(String id) async {
    return _collectionEventi.doc(id).get().then((document) => document.exists?
        Event.fromMap(document.id,  _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!) : null);
  }

  Future<List<Event>> getEvents() async { //this is db null safe, do we need it?
    return _collectionEventi.orderBy(Constants.tabellaEventi_dataInizio).get().then((snapshot) => snapshot.docs.map((document) =>
        Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList());
  }

  Stream<List<Event>> subscribeEvents() {
    return _collectionEventi.orderBy(Constants.tabellaEventi_dataInizio, descending: true).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsByOperator(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsByOperatorAcceptedOrBelow(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isLessThanOrEqualTo: EventStatus.Accepted).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id,  _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsByOperatorWaiting(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isGreaterThanOrEqualTo: EventStatus.New).where(Constants.tabellaEventi_stato, isLessThanOrEqualTo: EventStatus.Seen).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> eventsByOperatorAcceptedOrAbove(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isGreaterThanOrEqualTo: EventStatus.Accepted).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> eventsByOperatorNewOrAbove(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isGreaterThanOrEqualTo: EventStatus.New).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> eventsByOperatorRefusedOrAbove(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isGreaterThanOrEqualTo: EventStatus.Refused).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> eventsHistory() {
    return _collectionSubStoricoEventi.orderBy(Constants.tabellaEventi_dataInizio, descending: true).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsDeleted() {
    return _collectionStoricoEliminati.orderBy(Constants.tabellaEventi_dataInizio).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsRefuse() {
    return _collectionStoricoRifiutati.orderBy(Constants.tabellaEventi_dataInizio).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsEnded() {
    return _collectionStoricoTerminati.orderBy(Constants.tabellaEventi_dataInizio).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Future<DocumentSnapshot> getDocument(CollectionReference table, String id) async {
    return await table.doc(id).get().then((doc) => doc);
  }

  Stream<List<Event>> subscribeEventsFiltered(Query table, Event e, Map<String,bool> categorySelected, bool filterStartDate, bool filterEndDate)  {

    if(e.title != ''){
      table = table.where(Constants.tabellaEventi_titolo, isGreaterThanOrEqualTo: e.title).where(Constants.tabellaEventi_titolo, isLessThanOrEqualTo: e.title + '~' );
    }

    if(e.customer.phone != ''){
      table = table.where(Constants.tabellaEventi_cliente+'.'+Constants.tabellaClienti_telefono, isGreaterThanOrEqualTo: e.customer.phone)
          .where(Constants.tabellaEventi_cliente+'.'+Constants.tabellaClienti_telefono, isLessThanOrEqualTo: e.customer.phone + '~' );
    }

    if(e.suboperators.isNotEmpty){
      table = table.where(Constants.tabellaEventi_idOperatori, arrayContains: [...e.suboperators.map((op) => op.id)]);
    }

    List<String> listCategory = categorySelected.keys.where((key) => categorySelected[key]!).toList();
    if(listCategory.isNotEmpty){
      table = table.where(Constants.tabellaEventi_categoria, whereIn: listCategory);
    }

    return table.orderBy(Constants.tabellaEventi_dataInizio, descending: true).limit(Constants.numDocuments).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      List<Event> listEvent = documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
      return listEvent.where((event) => event.isFilteredEventSimple(e.address, e.start, e.end, filterStartDate, filterEndDate)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsHistoryFiltered(Event e, Map<String,bool> categorySelected, bool filterStartDate, bool filterEndDate) {
    CollectionReference table = _collectionStoricoTerminati;
     if(e.isRefused()){
      table = _collectionStoricoRifiutati;
    }else if(e.isDeleted()){
      table = _collectionStoricoEliminati;
    }
    return subscribeEventsFiltered(table, e, categorySelected, filterStartDate, filterEndDate);
  }

  Stream<List<Event>> subscribeEventsWorkFiltered(Event e, Map<String,bool> categorySelected, bool filterStartDate, bool filterEndDate) {
    return subscribeEventsFiltered(_collectionEventi, e, categorySelected, filterStartDate, filterEndDate);
  }

  Future<String> addEvent(Event data) async {
    var docRef = await _collectionEventi.add(data.toDocument());
    return docRef.id;
  }

  Future<String> addEventPast(Event e) async {
    e.status = EventStatus.Ended;
    final dynamic createTransaction = (dynamic tx) async {
      dynamic doc = _collectionEventi.doc();
      dynamic endedDoc = _collectionStoricoTerminati.doc(doc.id);
      await tx.set(endedDoc, e.toDocument());
      await tx.set(doc,  e.toDocument());
      return doc.id;
    };
    return _cloudFirestore.runTransaction(createTransaction).then((idDoc) => idDoc);
  }

  void updateEvent(String id, Event data) {
    _collectionEventi.doc(id).update(data.toDocument());
  }

  void updateEventPast(String id, Event data) {
    data.status = EventStatus.Ended;
    final dynamic createTransaction = (dynamic tx) async {
      dynamic doc = _collectionEventi.doc(id);
      dynamic endedDoc = _collectionStoricoTerminati.doc(id);
      await tx.update(endedDoc, data.toDocument());
      await tx.update(doc, data.toDocument());
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  void updateEventField(String id, String field, dynamic data) {
    _collectionEventi.doc(id).update(Map.of({field:data}));
  }

  static void backgroundUpdateEventAsDelivered(String id) async {
    Event? event = await FirebaseFirestore.instance.collection(Constants.tabellaEventi).doc(id).get().then((document) => document.exists ?
      Event.fromMap(document.id, "", document.data()!));
      if (event != null && event.isNew()) {
        FirebaseFirestore.instance.collection(Constants.tabellaEventi).doc(id).update(Map.of({Constants.tabellaEventi_stato: EventStatus.Delivered})
      );
    }
  }

  Future<void> updateAccountField(String id, String field, dynamic data) async {
    return _collectionUtenti.doc(id).update(Map.of({field:data}));
  }

  void deleteEvent(Event e) async {
    e.status = EventStatus.Deleted;
    final dynamic createTransaction = (dynamic tx) async {
        dynamic doc = _collectionEventi.doc(e.id);
        dynamic deletedDoc = _collectionStoricoEliminati.doc(e.id);
        await tx.set(deletedDoc, e.toDocument());
        await tx.delete(doc);
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  void deleteEventPast(Event e) async {
    e.status = EventStatus.Deleted;
    final dynamic createTransaction = (dynamic tx) async {
      dynamic doc = _collectionEventi.doc(e.id);
      dynamic endedDoc = _collectionStoricoTerminati.doc(e.id);
      dynamic deletedDoc = _collectionStoricoEliminati.doc(e.id);
      await tx.set(deletedDoc, e.toDocument());
      await tx.delete(endedDoc);
      await tx.delete(doc);
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  void endEvent(Event e, {bool propagate = false}) async {
    e.status = EventStatus.Ended;
    var eventsMoved = [];
    if(propagate) {
      e.end = DateTime.now();
      var eventsToPropagate = [e];
      while(eventsToPropagate.isNotEmpty) {
        Event e = eventsToPropagate.removeLast();
        for(var operator in [e.operator, ...e.suboperators]){
          if(operator != null) {
            List<Event> eventsInConflict = await _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: operator.id).where(Constants.tabellaEventi_dataInizio, isGreaterThan: e.start, isLessThanOrEqualTo: e.end)
                .get().then(((snapshot) => snapshot.docs.map((document) => Event.fromMap(document.id, "", document.data()!)).toList()));
            eventsInConflict.forEach((eventInConflict) {
              Duration d = eventInConflict.end.difference(eventInConflict.start.add(Duration(minutes: 5)));
              eventInConflict.start = TimeUtils.getStartWorkTimeSpan(from: e.end.add(new Duration(minutes: 5)), ofDuration: d);
              eventInConflict.end =  eventInConflict.start.add(d);
              eventsToPropagate.add(eventInConflict);
            });
          }
        }
        eventsMoved.add(e);
      }
    }
    final dynamic createTransaction = (dynamic tx) async {
      dynamic doc = _collectionEventi.doc(e.id);
      dynamic endedDoc = _collectionStoricoTerminati.doc(e.id);
      await tx.set(endedDoc, e.toDocument());
      await tx.update(doc, {Constants.tabellaEventi_stato: e.status});
      for (var eventMoved in eventsMoved) {
        dynamic doc = _collectionEventi.doc(eventMoved.id);
        await tx.update(doc, {Constants.tabellaEventi_dataInizio: eventMoved.start});
        await tx.update(doc, {Constants.tabellaEventi_dataFine: eventMoved.end});
      }
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  void refuseEvent(Event e) async {
    e.status = EventStatus.Refused;
    final dynamic createTransaction = (dynamic tx) async {
      dynamic doc = _collectionEventi.doc(e.id);
      dynamic refusedDoc = _collectionStoricoRifiutati.doc(e.id);
      await tx.set(refusedDoc, e.toDocument());
      await tx.update(doc, {Constants.tabellaEventi_stato:e.status});
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  Future<Account> getUserByPhone(String phoneNumber) async{
    return _collectionUtenti.where('Telefono', isEqualTo: phoneNumber).get().then((snapshot) => snapshot.docs.map((document) => Account.fromMap(document.id, document.data()!)).first);
  }

  String _getColorByCategory(String? category) =>
    categories[category??Constants.categoryDefault]??Constants.fallbackHexColor;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}

//  AuthUser _userFromFirebase(fb.User user) {
//
//    if (user == null) {
//      return null;
//    }
//    return AuthUser (
//      uid: user.uid,
//      email: user.email,
//      displayName: user.displayName,
//      photoUrl: user.photoURL,
//    );
//  }
//
//  Stream<AuthUser> get onAuthStateChanged {
//    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
//  }
