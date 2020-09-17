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
import 'package:venturiautospurghi/utils/global_contants.dart';
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
    state.locations = await getLocationAddresses(text);
    emit(state);
  }

  setAddress(String address) {
    state.event.address = address;
    emit(CreateEventState(state.event));
  }

  bool isNew() => this._type == _eventType.create;

  Future<bool> saveEvent() async {
    if (state.event.operator == null)
      return PlatformUtils.notifyErrorMessage("Assegna un'operatore di riferimento.");

    if((this.formTimeControlsKey.currentState.validate() || !this.canModify) && formKey.currentState.validate()) {
      formKey.currentState.save();
      state.status = _formStatus.loading;
      //get all data before refresh
      emit(state);
      try {
        if(Constants.debug) print("Firebase save " + state.event.start.toString() + " : " + state.event.end.toString());
        state.event.supervisor = _account.toDocument();
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
        List<String> cloudFiles = PlatformUtils.storageGetFiles(state.event.id + "/" ) ?? List<String>();
        //TODO dunno if this list contains id/name or just list of name, the method down here is for just names
        state.documents.forEach((key, value) {
          if(cloudFiles.contains(key)) {
            if (!value.isNullOrEmpty()) {
              PlatformUtils.storageDelFile(state.event.id + "/" + key);
              PlatformUtils.storagePutFile(state.event.id + "/" + key, PlatformUtils.file(value));
            }
            cloudFiles.remove(key);
          }
        });
        cloudFiles.forEach((file) => PlatformUtils.storageDelFile(state.event.id + "/" + file));
        if(Constants.debug) print("FireStorage upload comeplete");
        FirebaseMessagingService.sendNotification(token: state.event.operator["Token"], eventId: state.event.id);
        if(Constants.debug) print("FireMessaging notified");
      } catch (e) {
        state.status = _formStatus.normal;
        emit(state);
        print(e);
        return PlatformUtils.notifyErrorMessage("Errore nella creazione dell'evento.");
      }
    }
  }


  removeDocument(String name) {
    state.documents.remove(name);
    emit(state);
  }

  void openFileExplorer() async {
    try {
        Map<String,String> files = await PlatformUtils.multiFilePicker();
        files.forEach((key, value) {
          if(state.documents[key]!=null) {
            //TODO ask if you want to substitute the file and proceed
          } else {
            //moved out of the if for the moment
          }
          state.documents[key] = value;
        });
        emit(state);
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
        event.start = TimeUtils.getNextWorkTimeSpan(event.start);
        event.end = TimeUtils.addWorkTime(event.start, minutes: Constants.WORKTIME_SPAN);
      }
      _removeAllOperators(event);
      emit(state.assign(event: event));
    }else{
      PlatformUtils.notifyErrorMessage("Inserisci un intervallo temporale valido");
    }
  }

  setStartDate(DateTime date) {
    Event event = Event.fromMap("", "", state.event.toMap());
    event.start = date.add(Duration(hours: state.event.start.hour, minutes: state.event.start.minute));
    _removeAllOperators(event);
    emit(state.assign(event: event));
  }

  setStartTime(DateTime time) {
    Event event = Event.fromMap("", "", state.event.toMap());
    event.start = time;
    event.end = TimeUtils.truncateDate(event.end, "day").add(
        Duration(hours: TimeUtils.getNextWorkTimeSpan(event.start.OlderBetween(event.end)).hour,
            minutes: TimeUtils.getNextWorkTimeSpan(event.start.OlderBetween(event.end)).minute ));
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
    event.end = time.add(Duration(hours: state.event.end.hour, minutes: state.event.end.minute));
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
    // //starttime date
    // is DateTime
    // //starttime time
    //
    // if (event.isAllDayLong()) return null;
    // if (!value.isNullOrEmpty()) {
    //   DateTime newTime = value as DateTime;
    //   DateTime now = DateTime.now();
    //   if (newTime.hour >= Constants.MIN_WORKTIME && newTime.hour < Constants.MAX_WORKTIME &&
    //       (TimeUtils.truncateDate(event.start, "day") != TimeUtils.truncateDate(now, "day") ? true :
    //       (newTime.hour > now.hour || (newTime.hour == now.hour && newTime.minute > now.minute + 5)))) {
    //     return null;
    //   }
    // }
    // return 'Inserisci un orario valido';

    // //endtime date
    //
    // if (event.isAllDayLong()) return null;
    // if (value.isNullOrEmpty()) {
    //   return 'Inserisci una data valida';
    // }
    // return null;
    //
    // //endtime time
    //
    // if (event.isAllDayLong()) return null;
    // if (!value.isNullOrEmpty()) {
    //   DateTime newTime = value as DateTime;
    //   DateTime now = DateTime.now();
    //   if (newTime.hour >= Constants.MIN_WORKTIME && newTime.hour < Constants.MAX_WORKTIME &&
    //       (TimeUtils.truncateDate(event.start, "day") != TimeUtils.truncateDate(now, "day") ? true :
    //       (newTime.hour > now.hour || (newTime.hour == now.hour && newTime.minute > now.minute + 5)))) {
    //     return null;
    //   }
    // }
    //
    // if (!formTimeControlsKey.currentState.validate())//TODO time check
    //   return PlatformUtils.notifyErrorMessage("Inserisci un intervallo temporale valido");
    PlatformUtils.navigator(context, Constants.operatorListRoute, [state.event,true]);
  }

  void forceRefresh() {
    emit(state.assign(status: _formStatus.loading));
    emit(state.assign(status: _formStatus.normal));
  }
}