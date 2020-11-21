import 'package:bloc/bloc.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
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
  TextEditingController addressController;

  _eventType _type;
  bool canModify;
  Map<String,dynamic> categories;

  CreateEventCubit([this._databaseRepository, this._account, Event event])
      : assert(_databaseRepository != null && _account != null), super(CreateEventState(event)) {
    _type = (event==null)? _eventType.create : _eventType.modify;
    canModify = isNew() ? true : !(state.event.start.isAfter(DateTime.now()) && state.event.start.isBefore(DateTime.now().subtract(Duration(minutes: 5))));
    categories = _databaseRepository.categories;
    addressController = new TextEditingController();
    if(event != null ){
      if(!event.category.isNullOrEmpty()){
          radioValueChanged(categories.keys.toList().indexOf(event.category));
      }

      addressController.text = state.event.address??"";

    }

  }

  void getLocations(String text) async {
    if(text.length >5){
      List<String> locations = await getLocationAddresses(text);
      emit(state.assign(locations: locations, address: text));
    } else emit(state.assign(address: text));
  }

  setAddress(String address) {
    addressController.text = address;
    emit(state.assign(locations: new List<String>(), address: address));
  }

  bool isNew() => this._type == _eventType.create;

  Future<bool> saveEvent() async {
    if(state.event.end.isBefore(state.event.start))
      PlatformUtils.notifyErrorMessage("Seleziona un orario di fine incarico valido");
    if (state.event.operator == null)
      PlatformUtils.notifyErrorMessage("Assegna un'operatore di riferimento.");
    else if (state.category == null || state.category == -1)
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

        bool sendNotification = true;
        if(state.isScheduled){
          state.event.status = Status.Accepted;
          sendNotification = false;
        }else if(state.event.end.isBefore(DateTime.now())){
          sendNotification = false;
        }else{
          state.event.status = Status.New;
        }

        state.event.documents = state.documents.keys.toList();
        if(this.isNew()) {
          state.event.id = state.event.end.isBefore(DateTime.now())?
             await _databaseRepository.addEventPast(state.event): await _databaseRepository.addEvent(state.event);
        } else {
          state.event.end.isBefore(DateTime.now())?
              _databaseRepository.updateEventPast(state.event.id, state.event):
              _databaseRepository.updateEvent(state.event.id, state.event);
        }
        if(Constants.debug) print("Firebase save complete");
        if(Constants.debug) print("FireStorage upload");
        List<String> cloudFiles = (await PlatformUtils.storageGetFiles(state.event.id + "/" )) ?? List<String>();
        state.documents.forEach((name, file) {
            if (file != null) {
              if(cloudFiles.contains(name)) {
                PlatformUtils.storageDelFile(state.event.id + "/" + name);
                cloudFiles.remove(name);
              }
              PlatformUtils.storagePutFile(state.event.id + "/" + name, file);
            } else if(cloudFiles.contains(name)) cloudFiles.remove(name);
        });
        cloudFiles.forEach((name) => PlatformUtils.storageDelFile(state.event.id + "/" + name));
        if(Constants.debug) print("FireStorage upload comeplete");
        if(sendNotification){
            FirebaseMessagingService.sendNotifications(tokens: state.event.operator.tokens, eventId: state.event.id);
        }
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
    Map<String,PlatformFile> newDocs = Map.from(state.documents);
    newDocs.remove(name);
    emit(state.assign(documents: newDocs));
  }

  void openFileExplorer() async {
    try {
        Map<String,PlatformFile> files = Map.fromIterable((await FilePicker.platform.pickFiles(allowMultiple: true, withData: false)).files, key: (file)=>(file as PlatformFile).name, value: (file)=>file );
        Map<String,PlatformFile> newDocs = Map.from(state.documents);
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
    if(value) {
      event.start = TimeUtils.truncateDate(event.start, "day").add(Duration(hours: Constants.MIN_WORKTIME));
      event.end = TimeUtils.truncateDate(event.start, "day").add(Duration(hours: Constants.MAX_WORKTIME));
    } else {
      event.start = event.start;
      event.end = TimeUtils.addWorkTime(event.start, minutes: Constants.WORKTIME_SPAN);
    }
    _removeAllOperators(event);
    emit(state.assign(event: event, allDayFlag: value));
  }

  void setIsScheduled(value){
    emit(state.assign(isScheduled: value));
  }

  setAllDayDate(DateTime date){
    Event event = Event.fromMap("", "", state.event.toMap());
    event.start = TimeUtils.truncateDate(date, "day").add(Duration(hours: Constants.MIN_WORKTIME));
    event.end = TimeUtils.truncateDate(date, "day").add(Duration(hours: Constants.MAX_WORKTIME));
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }

  setStartDate(DateTime date) {
    Event event = Event.fromMap("", "", state.event.toMap());
    event.start = TimeUtils.getNextWorkTimeSpan(date);
    event.end = TimeUtils.getNextWorkTimeSpan(event.start).OlderBetween(event.end);
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }

  setStartTime(dynamic time) {
    Event event = Event.fromMap("", "", state.event.toMap());
    if(time is TimeOfDay) 
      time = TimeUtils.truncateDate(event.start, "day").add(Duration(hours: DateTimeField.convert(time).hour, minutes: DateTimeField.convert(time).minute));
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
  setEndTime(dynamic time) {
    Event event = Event.fromMap("", "", state.event.toMap());
    if(time is TimeOfDay)
      time = TimeUtils.truncateDate(event.end, "day").add(Duration(hours: DateTimeField.convert(time).hour, minutes: DateTimeField.convert(time).minute));
    event.end = time;
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
    if(state.event.start.hour < Constants.MIN_WORKTIME || state.event.start.hour >= Constants.MAX_WORKTIME )
        return PlatformUtils.notifyErrorMessage("Inserisci un'orario iniziale valido");
    if(state.event.end.hour < Constants.MIN_WORKTIME || (state.event.end.hour > Constants.MAX_WORKTIME && !state.event.isAllDayLong()) )
        return PlatformUtils.notifyErrorMessage("Inserisci un'orario finale valido");

    PlatformUtils.navigator(context, Constants.operatorListRoute, {'event' : state.event, 'requirePrimaryOperator' : true, 'context' : context});
  }

  void forceRefresh() {
    emit(state.assign(status: _formStatus.loading));
    emit(state.assign(status: _formStatus.normal));
  }
}