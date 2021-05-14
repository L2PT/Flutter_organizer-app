import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/models/filter_wrapper.dart';
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

  Future<List<Account>> getOperatorsFree(String eventIdToIgnore, DateTime fromDate, DateTime toDate, {limit, startFrom}) async {
    bool endOfList = false;
    List<Account> accounts = await this.getOperators(limit: limit, startFrom: startFrom);

    if(limit != null && accounts.length < limit) endOfList = true;

    final List<Event> listEvents = await this.getFutureEvents(fromDate);
    if(Constants.debug){
      listEvents.forEach((event) async {
        if (event.status == EventStatus.Refused || event.status == EventStatus.Deleted) {
          _collectionEventi.doc(event.id).delete();
        }
      });
      listEvents.removeWhere((event) => event.status == EventStatus.Refused || event.status == EventStatus.Deleted);
    }
    listEvents.forEach((event) {
      if (event.id != eventIdToIgnore) {
        if (event.isBetweenDate(fromDate, toDate)) {
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
    return accounts.length==limit || endOfList ? accounts :
      [...accounts, ...(await getOperatorsFree(eventIdToIgnore, fromDate, toDate, limit: limit-accounts.length, startFrom: accounts.last.surname))];
  }

  Future<List<Account>> getOperators({limit, startFrom}) async {
    Query query = _collectionUtenti.orderBy(Constants.tabellaUtenti_Cognome);
    query = addPagination(query, limit, startFrom);
    return query.get().then((snapshot) => snapshot.docs.map((document) => Account.fromMap(document.id, document.data()!)).toList());
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

  Stream<Map<String, dynamic>> getInfoApp() {
    return _collectionCostanti.doc(Constants.tabellaCostanti_InfoApp).snapshots().map((document)  => document.data()!);
  }

  Future<Map<String, dynamic>> getPhoneNumbers() async {
    return _collectionCostanti.doc(Constants.tabellaCostanti_Telefoni).get().then((document) => document.data()!);
  }

  Future<Event?> getEvent(String id) async {
    return _collectionEventi.doc(id).get().then((document) => document.exists?
        Event.fromMap(document.id,  _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!) : null);
  }

  Future<List<Event>> getEvents() async {
    return _collectionEventi.orderBy(Constants.tabellaEventi_dataInizio).get().then((snapshot) => snapshot.docs.map((document) =>
        Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList());
  }

  Future<List<Event>> getFutureEvents(DateTime date) async {
    date = date.subtract(Duration( days: 1));
    return _collectionEventi.where(Constants.tabellaEventi_dataInizio, isGreaterThanOrEqualTo:  date).orderBy(Constants.tabellaEventi_dataInizio).get().then((snapshot) => snapshot.docs.map((document) =>
        Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList());
  }

  Stream<List<Event>> subscribeEvents() {
    return _collectionEventi.orderBy(Constants.tabellaEventi_dataInizio, descending: true).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }

  Stream<List<Event>> subscribeEventsByOperatorWaiting(String idOperator) {
    return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator).where(Constants.tabellaEventi_stato, isGreaterThanOrEqualTo: EventStatus.New).where(Constants.tabellaEventi_stato, isLessThanOrEqualTo: EventStatus.Seen).snapshots().map((snapshot) {
      var documents = snapshot.docs;
      return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    });
  }// TODO merge subscription queries

  Stream<List<Event>> subscribeEventsByOperator(String idOperator, {required int statusEqualOrAbove, DateTime? from, DateTime? to}) {
    if(from != null && to != null)
      return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator)
          .where(Constants.tabellaEventi_dataInizio, isGreaterThanOrEqualTo: from)
          .where(Constants.tabellaEventi_dataInizio, isLessThan: to).snapshots().map((snapshot) {
        var documents = snapshot.docs;
        return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).where((event) => event.status>=statusEqualOrAbove).toList();
      });
    else
      return _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: idOperator)
          .where(Constants.tabellaEventi_stato, isGreaterThanOrEqualTo: statusEqualOrAbove).snapshots().map((snapshot) {
        var documents = snapshot.docs;
        return documents.map((document) => Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
      });
  }

  Stream<List<Event>> subscribeEventsHistory() {
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

  Future<List<Event>> _getEventsFiltered(Query query, Map<String, FilterWrapper> filters, [limit, startFrom, remaining]) async {
    Query startQuery = query;
    filters = Map.from(filters);
    // due to firebase limitations (we can't build a query with all filters) let the repository do ALL filtering work
    // despite some fields will be handled in the firebase query and some other in code
    bool endOfList = false;

    query = query.where(Constants.tabellaEventi_dataInizio, isLessThan: DateTime.now()).orderBy(Constants.tabellaEventi_dataInizio, descending: true);
    query = addPagination(query, limit, startFrom);

    // if(filters.containsKey("title") && filters["title"]!.fieldValue!=null){
    //   String title = filters.remove("title")!.fieldValue;
    //   query = query.where(Constants.tabellaEventi_titolo, isGreaterThanOrEqualTo: title).where(Constants.tabellaEventi_titolo, isLessThanOrEqualTo: title + '~' ).orderBy(Constants.tabellaEventi_titolo, descending: false);
    // }

    if(filters.containsKey("suboperators") && filters["suboperators"]!.fieldValue!=null){
      List<Account> suboperators = filters["suboperators"]!.fieldValue;
      if(suboperators.length>0){
        query = query.where(Constants.tabellaEventi_idOperatori, arrayContains: suboperators[0].id);
        if(suboperators.length==1) filters.remove("suboperators");
      }
    }

    if(filters.containsKey("categories") && filters["categories"]!.fieldValue!=null){
      Map<String,bool> categories = Map.from(filters.remove("categories")!.fieldValue);
      categories.removeWhere((key, value) => !value);
      if(categories.length>0) query = query.where(Constants.tabellaEventi_categoria, whereIn: categories.keys.toList());
    }

    var docs = await query.get().then((snapshot) => snapshot.docs);
    if(limit != null && docs.length < limit) endOfList = true;

    List<Event> events = docs.map((document) =>
        Event.fromMap(document.id, _getColorByCategory(document.get(Constants.tabellaEventi_categoria)), document.data()!)).toList();
    DateTime lastRetrieved = events.last.start;

    events = events.where((event) => filters.values.every((wrapper) =>
          event.filter(wrapper.filterFunction, wrapper.fieldValue))
    ).toList();

    var a = (events.length>=(remaining??limit) || endOfList) ? events :
      [...events, ...(await _getEventsFiltered(startQuery, filters, limit, lastRetrieved, limit-events.length))];
    return a;
  }

  Future<List<Event>> getEventsHistoryFiltered(int category, Map<String, FilterWrapper> filters, {limit, startFrom}) {
    CollectionReference table = _collectionStoricoTerminati;
    if(category == EventStatus.Refused){
      table = _collectionStoricoRifiutati;
    }else if(category == EventStatus.Refused){
      table = _collectionStoricoEliminati;
    }
    return _getEventsFiltered(table, filters, limit, startFrom);
  }

  Future<List<Event>> getEventsActiveFiltered(Map<String, FilterWrapper> filters, {limit, startFrom}) {
    return _getEventsFiltered(_collectionEventi, filters, limit, startFrom);
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
    Map<String, Event> eventsMoved = Map();
    if(propagate) {
      e.end = DateTime.now();
      var eventsToPropagate = [e];
      while(eventsToPropagate.isNotEmpty) {
        Event e = eventsToPropagate.removeLast();
        for(var operator in [e.operator, ...e.suboperators]){
          if(operator != null) {
            List<Event> eventsInConflict = await _collectionEventi.where(Constants.tabellaEventi_idOperatori, arrayContains: operator.id).where(Constants.tabellaEventi_dataInizio, isGreaterThan: e.start, isLessThanOrEqualTo: e.end)
                .get().then(((snapshot) => snapshot.docs.map((document) => Event.fromMap(document.id, "", document.data())).toList()));
            eventsInConflict.sort((a,b) => a.start.compareTo(b.start));
            Event eventConflict = e;
            eventsInConflict.forEach((eventInConflict) {
              Duration d = eventInConflict.end.difference(eventInConflict.start.add(Duration(minutes: 5)));
              eventInConflict.start = TimeUtils.getStartWorkTimeSpan(from: eventConflict.end.add(new Duration(minutes: 5)), ofDuration: d);
              eventInConflict.end =  eventInConflict.start.add(d);
              eventsToPropagate.add(eventInConflict);
              eventConflict = eventInConflict;
            });
          }
        }
        if(eventsMoved[e.id] == null || eventsMoved[e.id]!.start.isBefore(e.start))
            eventsMoved[e.id] = e;

      }
    }
    final dynamic createTransaction = (dynamic tx) async {
      dynamic doc = _collectionEventi.doc(e.id);
      dynamic endedDoc = _collectionStoricoTerminati.doc(e.id);
      await tx.set(endedDoc, e.toDocument());
      await tx.update(doc, {Constants.tabellaEventi_stato: e.status});
      for (Event eventMoved in eventsMoved.values){
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

  String _getColorByCategory(String? category) =>
    categories[category??Constants.categoryDefault]??Constants.fallbackHexColor;

  static void backgroundUpdateEventAsDelivered(String id) async {
    Event? event = await FirebaseFirestore.instance.collection(Constants.tabellaEventi).doc(id).get().then((document) => document.exists ? Event.fromMap(document.id, "", document.data()!) : null );
    if (event != null && event.isNew()) {
      FirebaseFirestore.instance.collection(Constants.tabellaEventi).doc(id).update(Map.of({Constants.tabellaEventi_stato: EventStatus.Delivered})
      );
    }
  }

  Query addPagination(Query query, [limit, startFrom]) {
    if (limit != null && startFrom != null)
      query = query.limit(limit).startAfter([startFrom]);
    else if (limit != null)
      query = query.limit(limit);
    else if (startFrom != null)
      query = query.startAfter([startFrom]);

    return query;
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> updateAccountField(String id, String field, dynamic data) async {
    return _collectionUtenti.doc(id).update(Map.of({field:data}));
  }

  Future<Account> getUserByPhone(String phoneNumber) async{
    return _collectionUtenti.where('Telefono', isEqualTo: phoneNumber).get().then((snapshot) => snapshot.docs.map((document) => Account.fromMap(document.id, document.data()!)).first);
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
