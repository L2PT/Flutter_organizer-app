import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/web_bloc/web_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/plugins/firebase/firebase_messaging.dart';
import 'package:venturiautospurghi/plugins/geo_location.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';

part 'create_event_state.dart';

enum _eventType{ create, modify }

class CreateEventCubit extends Cubit<CreateEventState> {

  final CloudFirestoreService _databaseRepository;
  final Account _account;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formTimeControlsKey = GlobalKey<FormState>();

  _eventType _type;
  bool canModify;
  Map<String,dynamic> categories;

  CreateEventCubit([this._databaseRepository, this._account, Event event])
      : assert(_databaseRepository != null && _account != null), super(CreateEventState(event)) {
    _type = (event==null)? _eventType.create : _eventType.modify;
    canModify = isNew() ? true : state.event.start.isBefore(DateTime.now().subtract(Duration(minutes: 5)));
    categories = _databaseRepository.categories;
  }

  void getLocations(String text) async {
    if(text.length >5){
      List<String> locations = await getLocationAddresses(text);
      emit(state.assign(locations: locations, address: text));
    }
  }

  setAddress(String address) {
    emit(state.assign(address: address));
  }

  bool isNew() => this._type == _eventType.create;

  Future<bool> saveEvent() async {
    if (state.event.operator == null)
      PlatformUtils.notifyErrorMessage("Assegna un'operatore di riferimento.");
    else if (state.category  == null)
      PlatformUtils.notifyErrorMessage("Seleziona una categoria valida.");
    else if((this.formTimeControlsKey.currentState.validate() || !this.canModify) && formKey.currentState.validate()) {
      //get all data before refresh
      formKey.currentState.save();
      emit(state.assign(status: _formStatus.loading));
      try {
        if(Constants.debug) print("Firebase save " + state.event.start.toString() + " : " + state.event.end.toString());
        state.event.supervisor = _account;
        int i=0;
        this.categories.forEach((key, value) { if(i++==state.category){
          state.event.category = key;
          state.event.color = value;
        }});
        state.event.status = Status.New;
        state.event.documents = state.documents.keys.toList();
        if(this.isNew()) {
          state.event.id = await _databaseRepository.addEvent(state.event);
        } else {
          _databaseRepository.updateEvent(state.event.id, state.event);
        }
        if(Constants.debug) print("Firebase save complete");
        if(Constants.debug) print("FireStorage upload");
        List<String> cloudFiles = (await PlatformUtils.storageGetFiles(state.event.id + "/" )) ?? List<String>();
        state.documents.forEach((name, path) {
            if (!path.isNullOrEmpty()) {
              if(cloudFiles.contains(name)) {
                PlatformUtils.storageDelFile(state.event.id + "/" + name);
                cloudFiles.remove(name);
              }
              PlatformUtils.storagePutFile(state.event.id + "/" + name, PlatformUtils.file(path));
            } else if(cloudFiles.contains(name)) cloudFiles.remove(name);
        });
        cloudFiles.forEach((file) => PlatformUtils.storageDelFile(state.event.id + "/" + file));
        if(Constants.debug) print("FireStorage upload comeplete");
        FirebaseMessagingService.sendNotification(token: state.event.operator.token, eventId: state.event.id);
        if(Constants.debug) print("FireMessaging notified");
        return true;
      } catch (e) {
        emit(state.assign(status: _formStatus.normal));
        print(e);
        PlatformUtils.notifyErrorMessage("Errore nella creazione dell'evento.");
      }
    }
    return false;
  }


  removeDocument(String name) {
    Map<String,String> newDocs = Map.from(state.documents);
    newDocs.remove(name);
    emit(state.assign(documents: newDocs));
  }

  void openFileExplorer() async {
    try {
        Map<String,String> files = await PlatformUtils.multiFilePicker();
        Map<String,String> newDocs = Map.from(state.documents);
        files.forEach((key, value) {
          newDocs[key] = value;
        });
        emit(state.assign(documents: newDocs));
    } on Exception catch (e) {
      print("Unsupported operation:" + e.toString());
    }
  }

  void radioValueChanged(int value) {
    emit(state.assign(category: value));
  }

  _removeAllOperators(Event event) {
    event.operator = null;
    event.suboperators = new List();
  }

  void setAlldayLong(value) {
    Event event = Event.fromMap("", "", state.event.toMap());
    if(TimeUtils.getNextWorkTimeSpan(TimeUtils.truncateDate(state.event.start, "day")).isAfter(DateTime.now())) {
      if(value) {
        event.start = TimeUtils.truncateDate(event.start, "day").add(Duration(hours: Constants.MIN_WORKTIME));
        event.end = TimeUtils.truncateDate(event.start, "day").add(Duration(hours: Constants.MAX_WORKTIME));
      } else {
        event.start = event.start;
        event.end = TimeUtils.addWorkTime(event.start, minutes: Constants.WORKTIME_SPAN);
      }
      _removeAllOperators(event);
      emit(state.assign(event: event, allDayFlag: value));
    }else{
      PlatformUtils.notifyErrorMessage("Inserisci un intervallo temporale valido");
    }
  }

  setStartDate(DateTime date) {
    Event event = Event.fromMap("", "", state.event.toMap());
    event.start = TimeUtils.getNextWorkTimeSpan(date);
    event.end = TimeUtils.getNextWorkTimeSpan(event.start).OlderBetween(event.end);
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }

  setStartTime(DateTime time) {
    Event event = Event.fromMap("", "", state.event.toMap());
    event.start = time;
    event.end = TimeUtils.truncateDate(event.end, "day").add(
        Duration(hours: (TimeUtils.getNextWorkTimeSpan(event.start).OlderBetween(event.end)).hour,
            minutes: (TimeUtils.getNextWorkTimeSpan(event.start).OlderBetween(event.end)).minute ));
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }

  setEndDate(DateTime date) {
    Event event = Event.fromMap("", "", state.event.toMap());
    event.end = TimeUtils.truncateDate(date, "day");
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }
  setEndTime(DateTime time) {
    Event event = Event.fromMap("", "", state.event.toMap());
    event.end = time.add(Duration(hours: event.end.hour, minutes: event.end.minute));
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }

  void removeSuboperatorFromEventList(Account suboperator) {
    Event event = Event.fromMap("", "", state.event.toMap());
    List subOps = new List.from(event.suboperators);
    subOps.removeWhere((element) => element.id == suboperator.id);
    event.suboperators = subOps;
    emit(state.assign(event: event));
  }


  void addOperatorDialog(BuildContext context) async {
    if(state.event.start.isBefore(DateTime.now().add(new Duration(minutes: 5))))
      return PlatformUtils.notifyErrorMessage("Inserisci un'intervallo temporale nel futuro");
    if(state.event.start.hour < Constants.MIN_WORKTIME || state.event.start.hour >= Constants.MAX_WORKTIME )
        return PlatformUtils.notifyErrorMessage("Inserisci un'orario iniziale valido");
    if(state.event.end.hour < Constants.MIN_WORKTIME || (state.event.end.hour >= Constants.MAX_WORKTIME && !state.event.isAllDayLong()) )
        return PlatformUtils.notifyErrorMessage("Inserisci un'orario finale valido");

    PlatformUtils.navigator(context, Constants.operatorListRoute, [state.event,true]);
  }

  void forceRefresh() {
    emit(state.assign(status: _formStatus.loading));
    emit(state.assign(status: _formStatus.normal));
  }
}