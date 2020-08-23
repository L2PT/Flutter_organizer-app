import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';

class CloudFirestoreService {

  final cf.FirebaseFirestore _cloudFirestore;
  cf.CollectionReference _collectionUtenti;
  cf.CollectionReference _collectionEventi;
  cf.CollectionReference _collectionSubStoricoEventi;
  cf.CollectionReference _collectionStoricoEliminati;
  cf.CollectionReference _collectionStoricoTerminati;
  cf.CollectionReference _collectionStoricoRifiutati;
  cf.CollectionReference _collectionCostanti;

  Map<String,String> categories;

  CloudFirestoreService({cf.FirebaseFirestore cloudFirestore})
      : _cloudFirestore = cloudFirestore ??  cf.FirebaseFirestore.instance {
    _collectionUtenti = _cloudFirestore.collection(Constants.tabellaUtenti) ;
    _collectionEventi = _cloudFirestore.collection(Constants.tabellaEventi);
    _collectionSubStoricoEventi = _cloudFirestore.collectionGroup(Constants.subtabellaStorico);
    _collectionStoricoEliminati = _cloudFirestore.collection(Constants.tabellaEventiEliminati);
    _collectionStoricoTerminati = _cloudFirestore.collection(Constants.tabellaEventiTerminati);
    _collectionStoricoRifiutati = _cloudFirestore.collection(Constants.tabellaEventiRifiutati);
    _collectionCostanti = _cloudFirestore.collection(Constants.tabellaCostanti);
  }

  static Future<CloudFirestoreService> create({cf.FirebaseFirestore cloudFirestore}) async {
    CloudFirestoreService instance = CloudFirestoreService(cloudFirestore:cloudFirestore);
    instance.categories = await instance._getCategories();
    return instance;
  }

  Future<List<Account>> getOperatorsFree(String eventIdToIgnore, DateTime startFrom, DateTime endTo) async {
    final List<Account> accounts = await this.getOperators();

    final List<Event> listEvents = await this.getEvents();

    listEvents.forEach((event) {
      if (event.id != eventIdToIgnore) {
        if (event.isBetweenDate(startFrom, endTo)) {
          event.idOperators.forEach((idOperator) {
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
    return _collectionUtenti.get().then((snapshot) => snapshot.docs.map((document) => Account.fromMap(document.id, document.data())).toList());
  }

  void addOperator(Account u) {
    _collectionUtenti.doc(u.id).set(u.toDocument());
  }

  void updateOperator(String id, String field, dynamic data) {
    _collectionUtenti.doc(id).update(Map.of({field:data}));
  }

  void deleteOperator(String id) {
    _collectionUtenti.doc(id).delete();
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<Map<String, String>> _getCategories() async {
    return (await _collectionCostanti.doc(Constants.tabellaCostanti_Categorie).get()).data();
  }

  Future<Event> getEvent(String id) async {
    return _collectionEventi.doc(id).get().then((document) =>
        Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data()));
  }

  Future<List<Event>> getEvents() async {
    return _collectionEventi.get().then((snapshot) => snapshot.docs.map((document) =>
        Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data())).toList());
  }

  Stream<List<Event>> subscribeEvents() {
    return _collectionEventi.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data()));
    });
  }

  Stream<List<Event>> subscribeEventsByOperator(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data()));
    });
  }

  Stream<List<Event>> subscribeEventsByOperatorAcceptedOrAbove(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isGreaterThanOrEqualTo: Status.Accepted).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data()));
    });
  }

  Stream<List<Event>> subscribeEventsByOperatorWaiting(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isLessThanOrEqualTo: Status.Seen).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data()));
    });
  }

  // TODO check that it (still, since is just a refactored code) fetch all the dictionaries.
  // expected -> snapshot per tutti gli eventi nello storico
  Stream<List<Event>> eventsHistory() {
    return _collectionSubStoricoEventi.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data()));
    });  }

  /*TODO i would like to know if the stream need to update (only the change come from into the stream)
         the data or refresh (every time a change occour the full data list come into the stream) */
  Stream<List<Event>> subscribeEventsDeleted() {
    return _collectionStoricoEliminati.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data()));
    });
  }

  Stream<List<Event>> subscribeEventsEnded() {
    return _collectionStoricoTerminati.snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, categories[document.get(Constants.tabellaEventi_categoria)??"default"], document.data()));
    });
  }

  Future<String> addEvent(dynamic data) async {
    var docRef = await _collectionEventi.add(data);
    return docRef.id;
  }

  void updateEvent(String id, dynamic data) async {
    _collectionEventi.doc(id).update(data);
  }

  void deleteEvent(Event e) async {
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = _collectionEventi.doc(e.id);
      e.status = Status.Deleted; //this set is preventive (if all is done right it SHOULDN'T be necessary)
      await tx.set(_collectionStoricoTerminati.doc(e.id).update(e.toDocument()));
      await tx.update(dc, {Constants.tabellaEventi_stato:e.status});
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  void endEvent(Event e) {
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = _collectionEventi.doc(e.id);
      e.status = Status.Ended; //this set is preventive (if all is done right it SHOULDN'T be necessary)
      await tx.set(_collectionStoricoTerminati.doc(e.id).update(e.toDocument()));
      await tx.update(dc, {Constants.tabellaEventi_stato:e.status});
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

  void refuseEvent(Event e) async {
    final dynamic createTransaction = (dynamic tx) async {
      dynamic dc = _collectionEventi.doc(e.id);
      await tx.set(_collectionStoricoRifiutati.doc(e.id).update(e.toDocument()));
      await tx.delete(dc);
    };
    _cloudFirestore.runTransaction(createTransaction);
  }

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
