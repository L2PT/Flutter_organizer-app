import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'filter_event_state.dart';

class FilterEventCubbit extends Cubit<FilterEventState> {
  final CloudFirestoreService _databaseRepository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late Map<String,dynamic> categories;
  late TextEditingController titleController;
  late TextEditingController addressController;
  late TextEditingController customerController;

  List<Event> listEv = [];



  FilterEventCubbit(this._databaseRepository) : super(FilterEventState()) {
    titleController = new TextEditingController();
    addressController = new TextEditingController();
    customerController = new TextEditingController();
    titleController.text = state.eventFilter.title;
    addressController.text= state.eventFilter.address;
    customerController.text= state.eventFilter.customer.phone;
    getCategory();
  }
  
  void showFiltersBox() {
    emit(state.assign(filtersBoxVisibile:!state.filtersBoxVisibile, enableSearchField: !state.enableSearchField));
  }

  void onSearchChanged(String text, void Function(Event e, Map<String,bool> categorySelected, bool filterStartDate, bool filterEndDate) filterEvent){
    Event e = Event.empty();
    e.title = text;
    filterEvent(e, Map(), false, false);
  }

  void getCategory() async {
    categories = _databaseRepository.categories;
    Map<String,bool> categorySelected = new Map.from(state.categorySelected);
    categories.keys.forEach((category) { categorySelected[category] = false; });
    emit(state.assign(categorySelected: categorySelected));
  }

  void addOperatorDialog(BuildContext context) async {
    if(formKey.currentState!.validate()){
      formKey.currentState!.save();
      PlatformUtils.navigator(context, Constants.operatorListRoute, {'event' : state.eventFilter, 'requirePrimaryOperator' : false, 'context' : context, 'callback' : forceRefresh});
    }
  }

  void removeOperatorFromEventList(Account operator) {
    Event event = Event.fromMap("", "", state.eventFilter.toMap());
    List<Account> ops = new List.from(event.suboperators);
    ops.removeWhere((element) => element.id == operator.id);
    event.suboperators = ops;
    emit(state.assign(eventFilter: event));
  }

  setStartDate(DateTime date) {
    Event event = Event.fromMap("", "", state.eventFilter.toMap());
    event.start = TimeUtils.truncateDate(date, "day");
    emit(state.assign(eventFilter: event, filterStartDate: true));
  }

  clearStartDate(){
    Event event = Event.fromMap("", "", state.eventFilter.toMap());
    event.start = TimeUtils.truncateDate(DateTime.now(), "day");
    emit(state.assign(eventFilter: event, filterStartDate: false));
  }

  setEndDate(DateTime date) {
    Event event = Event.fromMap("", "", state.eventFilter.toMap());
    event.end = TimeUtils.truncateDate(date, "day");
    emit(state.assign(eventFilter: event, filterEndDate: true));
  }

  clearEndDate() {
    Event event = Event.fromMap("", "", state.eventFilter.toMap());
    event.end = TimeUtils.truncateDate(DateTime.now(), "day");
    emit(state.assign(eventFilter: event, filterEndDate: false));
  }

  checkCategory(String name, bool? value){
    Map<String,bool> categorySelected = new Map.from(state.categorySelected);
    if(categorySelected.containsKey(name)) {
      categorySelected[name] = value??false;
    }
    emit(state.assign(categorySelected: categorySelected));
  }

  bool getCategorySelected(String categoryName){
    return state.categorySelected[categoryName]?? false;
  }

  void forceRefresh() {
    emit(state.assign(status: _filterStatus.loading));
    emit(state.assign(status: _filterStatus.normal));
  }

  void clearFilter(){
    titleController.text = '';
    addressController.text= '';
    customerController.text= '';
    Map<String,bool> categorySelected = new Map.from(state.categorySelected);
    categories.keys.forEach((category) { categorySelected[category] = false; });
    emit(state.assign(eventFilter: Event.empty(), categorySelected: categorySelected, filterEndDate: false, filterStartDate: false));
  }

  void filterValue(void Function(Event e, Map<String,bool> categorySelected, bool filterStartDate, bool filterEndDate) filterEvent){
    if(formKey.currentState!.validate()){
      formKey.currentState!.save();
      filterEvent(state.eventFilter, state.categorySelected, state.filterStartDate, state.filterEndDate);
      emit(state.assign(filtersBoxVisibile:!state.filtersBoxVisibile));
    }
  }

}