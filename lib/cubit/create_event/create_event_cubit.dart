import 'package:bloc/bloc.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_messaging_service.dart';
import 'package:venturiautospurghi/repositories/firebase_storage_service.dart';
import 'package:venturiautospurghi/utils/file_utils.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';

part 'create_event_state.dart';

enum _eventType{ create, modify, copy }

class CreateEventCubit extends Cubit<CreateEventState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  final GlobalKey<FormState> formKeyAssignedInfo = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyBasiclyInfo = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyClientInfo = GlobalKey<FormState>();
  final GlobalKey<FormState> formTimeControlsKey = GlobalKey<FormState>();
  late TextEditingController addressController;

  late _eventType _type;
  late bool canModify;
  late Map<String,dynamic> categories;
  late Map<String,dynamic> types;
  late Map<int, GlobalKey<FormState>> forms;
  DateTime? firstClick;

  CreateEventCubit(this._databaseRepository, this._account, Event? event)
      : super(CreateEventState(event)) {
    fillMapForms();
    if(event==null){
      _type = _eventType.create;
      state.event.supervisor = _account;
    } else if(event.id == '') {
      _type = _eventType.copy;
    }else _type = _eventType.modify;
      canModify = isNew() ? true : !(state.event.start.isAfter(DateTime.now()) && state.event.start.isBefore(DateTime.now().subtract(Duration(minutes: 5))));
      categories = _databaseRepository.categories;
      types = _databaseRepository.types;
      addressController = new TextEditingController();
      if(event != null ){
        if(!string.isNullOrEmpty(event.category)){
          onSelectedCategory(event.category);
        }
        addressController.text = state.event.address;
      }
  }

  void getLocations(String text) async {
    if(text.length > 5 && text != state.event.address){
      List<String> locations = [];
      if(PlatformUtils.isMobile){
        locations = await GeoUtils.getLocations(text);
      }else{
        locations = await GeoUtils.getLocationsWeb(text);
      }
      emit(state.assign(locations: locations, address: text));
    }
  }

  setAddress(String address) {
    addressController.text = address;
    emit(state.assign(locations: <String>[], address: address));
  }

  bool isNew() => this._type == _eventType.create;

  bool isCopy() => this._type == _eventType.copy;

  Future<bool> saveEvent() async {
    if(state.isLoading()) return Future<bool>(()=>false);
    if(state.event.end.isBefore(state.event.start))
      PlatformUtils.notifyErrorMessage("Seleziona un'orario di fine incarico valido");
    else if((this.formTimeControlsKey.currentState!.validate() || !this.canModify) && formKeyAssignedInfo.currentState!.validate()) {
      //get all data before refresh
      formKeyAssignedInfo.currentState!.save();
      emit(state.assign(status: _formStatus.loading));
      try {
        if (Constants.debug) print(
            "Firebase save " + state.event.start.toString() + " : " +
                state.event.end.toString());
        state.event.supervisor = _account;
        state.event.category = state.category;
        state.event.color = this.categories[state.category];
        if(state.typeSelected == 'Contratto') state.event.title = state.typeSelected + " - " + state.event.title;

        bool sendNotification = true;
        if (state.event.operator == null){
          state.event.status = EventStatus.Bozza;
          sendNotification = false;
        } else if (state.isScheduled) {
          state.event.status = EventStatus.Accepted;
          sendNotification = false;
        } else if (state.event.end.isBefore(DateTime.now())) {
          sendNotification = false;
        } else{
          state.event.status = EventStatus.New;
        }

        state.event.documents = state.documents.keys.toList();
        if(this.isNew() || this.isCopy()) {
          state.event.id = state.event.end.isBefore(DateTime.now())?
             await _databaseRepository.addEventPast(state.event): await _databaseRepository.addEvent(state.event);
        } else {
          state.event.end.isBefore(DateTime.now())?
              _databaseRepository.updateEventPast(state.event.id, state.event):
              _databaseRepository.updateEvent(state.event.id, state.event);
        }
        if(Constants.debug) print("Firebase save complete");
        if(Constants.debug) print("FireStorage upload");
        ListResult cloudResults = await FirebaseStorageService.listFiles(state.event.id + "/" );
        List<String> cloudFiles = cloudResults.items.map((file) => file.name).toList();
        state.documents.forEach((name, file) {
            if (file != null) {
              if(cloudFiles.contains(name)) {
                FirebaseStorageService.deleteFile(state.event.id + "/" + name);
                cloudFiles.remove(name);
              }
              FirebaseStorageService.uploadFile(file, state.event.id + "/" + name);
            } else if(cloudFiles.contains(name)) cloudFiles.remove(name);
        });
        cloudFiles.forEach((name) => FirebaseStorageService.deleteFile(state.event.id + "/" + name));
        if(Constants.debug) print("FireStorage upload comeplete");
        if(sendNotification){
            FirebaseMessagingService.sendNotifications(tokens: state.event.operator!.tokens, title: "Nuovo incarico assegnato", eventId: state.event.id);
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
    Map<String, dynamic> newDocs = Map.from(state.documents);
    newDocs.remove(name);
    emit(state.assign(documents: newDocs));
  }

  void openFileExplorer() async {
    Map<String, dynamic> newDocs = await FileUtils.openFileExplorer(state.documents);
    emit(state.assign(documents: newDocs));
  }

  _removeAllOperators(Event event) {
    event.operator = null;
    event.suboperators = [];
  }

  void setAlldayLong(value) {
    Event event = Event.fromMap("", "", state.event.toMap());
    if(value) {
      event.start = TimeUtils.truncateDate(event.start, "day").add(Duration(hours: Constants.MIN_WORKTIME));
      event.end = TimeUtils.truncateDate(event.start, "day").add(Duration(hours: Constants.MAX_WORKTIME));
    } else {
      event.start = event.start;
      event.end = TimeUtils.addWorkTime(event.start, Duration(minutes: Constants.WORKTIME_SPAN));
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
    event.start = TimeUtils.getStartWorkTimeSpan(from: date);
    event.end = TimeUtils.getStartWorkTimeSpan(from: event.start).olderBetween(event.end);
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }

  setStartTime(dynamic time) {
    Event event = Event.fromMap("", "", state.event.toMap());
    if(time is TimeOfDay) 
      time = TimeUtils.truncateDate(event.start, "day").add(Duration(hours: DateTimeField.convert(time)!.hour, minutes: DateTimeField.convert(time)!.minute));
    event.start = time;
    event.end = TimeUtils.truncateDate(event.end, "day").add(
        Duration(hours: (TimeUtils.getStartWorkTimeSpan(from: event.start).olderBetween(event.end)).hour,
            minutes: (TimeUtils.getStartWorkTimeSpan(from: event.start).olderBetween(event.end)).minute ));
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }

  setEndDate(DateTime date) {
    Event event = Event.fromMap("", "", state.event.toMap());
    event.end = TimeUtils.truncateDate(date, "day").add(
        Duration(hours: event.end.hour,
            minutes: event.end.minute));
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }
  
  setEndTime(dynamic time) {
    Event event = Event.fromMap("", "", state.event.toMap());
    if(time is TimeOfDay)
      time = TimeUtils.truncateDate(event.end, "day").add(Duration(hours: DateTimeField.convert(time)!.hour, minutes: DateTimeField.convert(time)!.minute));
    event.end = time;
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }

  void removeSuboperatorFromEventList(Account suboperator) {
    Event event = Event.fromMap("", "", state.event.toMap());
    List<Account> subOps = new List.from(event.suboperators);
    if(event.operator!.id == suboperator.id) {
      event.operator = null;
      subOps = [];
      event.suboperators = subOps;
    }
    if(subOps.isNotEmpty){
      subOps.removeWhere((element) => element.id == suboperator.id);
      event.suboperators = subOps;
    }
    emit(state.assign(event: event));
  }

  bool checkModifyOperator(Account operator) {
    return operator != state.event.operator && this.canModify;
  }

  void addOperatorDialog(BuildContext context) async {
    if(state.event.start.hour < Constants.MIN_WORKTIME || state.event.start.hour >= Constants.MAX_WORKTIME )
        return PlatformUtils.notifyErrorMessage("Inserisci un'orario iniziale valido");
    if(state.event.end.hour < Constants.MIN_WORKTIME || (state.event.end.hour > Constants.MAX_WORKTIME && !state.event.isAllDayLong()) )
        return PlatformUtils.notifyErrorMessage("Inserisci un'orario finale valido");
    //shh this is wrong, it breaks the mvvm
    PlatformUtils.navigator(context, Constants.operatorListRoute, <String, dynamic>{'event' : state.event, 'requirePrimaryOperator' : true, 'context' : context, 'callback': forceRefresh});
  }

  void forceRefresh() {
    emit(state.assign(status: _formStatus.loading));
    emit(state.assign(status: _formStatus.normal));
  }



  /* STEPPER CONTROLLER */
  void onStepContinue(int numberStep){
    if(state.currentStep != numberStep-1){
      GlobalKey<FormState>? form = forms[state.currentStep];
      if(form != null){
        if(form.currentState!.validate()){
          form.currentState!.save();
          emit(state.assign(currentStep: state.currentStep+1));
        }
      }else{
        emit(state.assign(currentStep: state.currentStep+1));
      }
    }
  }

  void onStepCancel(){
    if(state.currentStep != 0){
      emit(state.assign(currentStep: state.currentStep-1));
    }
  }

  void onStepTapped(int step){
    emit(state.assign(currentStep: step));
  }

  void onSelectedType(String key){
    emit(state.assign(typeSelected: key));
  }

  void onSelectedCategory(String key){
    emit(state.assign(category: key));
  }

  void fillMapForms(){
    forms = Map();
    forms.putIfAbsent(1, () => formKeyBasiclyInfo);
    forms.putIfAbsent(2, () => formKeyClientInfo);
  }

  void setFirstClick(DateTime date){
    firstClick = date;
  }
}