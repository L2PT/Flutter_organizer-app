import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/extensions.dart';

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
    return _collectionEventi.get().then((snapshot) => snapshot.docs.map((document) =>
      document.data()==null?Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!):null).toList().removeNulls<List<Event>>());
  }

  Stream<List<Event>> subscribeEvents() {
    return _collectionEventi.snapshots().map((snapshot) {
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
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isLessThanOrEqualTo: EventStatus.Seen).snapshots().map((snapshot) {
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

  Stream<List<Event>> eventsHistory() {
    return _collectionSubStoricoEventi.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsDeleted() {
    return _collectionStoricoEliminati.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsRefuse() {
    return _collectionStoricoRifiutati.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsEnded() {
    return _collectionStoricoTerminati.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
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

  void endEvent(Event e) {
    e.status = EventStatus.Ended;
    final dynamic createTransaction = (dynamic tx) async {
      dynamic doc = _collectionEventi.doc(e.id);
      dynamic endedDoc = _collectionStoricoTerminati.doc(e.id);
      await tx.set(endedDoc, e.toDocument());
      await tx.update(doc, {Constants.tabellaEventi_stato:e.status});
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  void refuseEvent(Event e) async {
    e.status = EventStatus.Refused;
    final dynamic createTransaction = (dynamic tx) async {
      dynamic doc = _collectionEventi.doc(e.id);
      dynamic refusedDoc = _collectionStoricoRifiutati.doc(e.id);
      await tx.set(refusedDoc, e.toDocument());
      await tx.delete(doc);
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
