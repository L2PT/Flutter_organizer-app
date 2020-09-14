import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/plugins/firebase/firebase_messaging.dart';
import 'package:venturiautospurghi/plugins/geo_location.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/views/screen_pages/operator_selection_view.dart';

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
            state.documents[key] = value;
          }
        });
        emit(state);
    } on Exception catch (e) {
      print("Unsupported operation:" + e.toString());
    }
  }

  void radioValueChanged(int value) {
    state.category = value;
    emit(state);
  }

  _removeAllOperators() {
    state.event.operator = null;
    state.event.suboperators = new List();
  }

  void setAlldayLong(value) {
    if(TimeUtils.getNextWorkTimeSpan(TimeUtils.truncateDate(state.event.start, "day")).isAfter(DateTime.now())) {
      if(value) {
        state.event.start = TimeUtils.truncateDate(state.event.start, "day").add(Duration(hours: Constants.MIN_WORKTIME));
        state.event.end = TimeUtils.truncateDate(state.event.start, "day").add(Duration(hours: Constants.MAX_WORKTIME));
      } else {
        state.event.start = TimeUtils.getNextWorkTimeSpan(state.event.start);
        state.event.end = TimeUtils.addWorkTime(state.event.start, minutes: Constants.WORKTIME_SPAN);
      }
      _removeAllOperators();
      emit(state);
    }else{
      //TODO segnala all'utente di cambiare data prima di settare alldaylong forse bisogna fere emit del valore a false
      PlatformUtils.notifyErrorMessage("Inserisci un intervallo temporale valido");
    }
  }

  setStartDate(DateTime date) {
    state.event.start = TimeUtils.truncateDate(date, "day");
    _removeAllOperators();
    emit(state);
  }
  setStartTime(DateTime time) {
    //TODO attention here probably it's just a time and not a DateTime
    state.event.start = TimeUtils.truncateDate(time, "day");
    _removeAllOperators();
    emit(state);
//    onSaved: (DateTime value) => widget._event.start = value != null
//        ? TimeUtils.truncateDate(widget._event.start, "day")
//        .add(Duration(hours: value.hour, minutes: value.minute))
//        : widget._event.start),
  }
  setEndDate(DateTime date) {
    state.event.start = TimeUtils.truncateDate(date, "day");
    _removeAllOperators();
    emit(state);
  }
  setEndTime(DateTime time) {
    //TODO attention here probably it's just a time and not a DateTime
    state.event.start = TimeUtils.truncateDate(time, "day");
    _removeAllOperators();
    emit(state);
//    onSaved: (DateTime value) => widget._event.end = value != null
//        ? TimeUtils.truncateDate(widget._event.end, "day")
//        .add(Duration(hours: value.hour, minutes: value.minute))
//        : widget._event.end),
  }

  void removeSuboperatorFromEventList(Account suboperator) {
    state.event.suboperators.removeWhere((element) => element["id"] == suboperator.id);
    emit(state);
  }


  void addOperatorDialog(BuildContext context) async {
    // if (!formTimeControlsKey.currentState.validate())//TODO time check
    //   return PlatformUtils.notifyErrorMessage("Inserisci un intervallo temporale valido");
    PlatformUtils.navigator(context, Constants.operatorListRoute, [state.event,true]);
    emit(state);
  }
}