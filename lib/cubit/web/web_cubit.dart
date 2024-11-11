import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/customer.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/models/filter_wrapper.dart';
import 'package:venturiautospurghi/plugins/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';

part 'web_state.dart';

class WebCubit extends Cubit<WebCubitState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  String route;
  final int range = 3;
  DateTime newDate = DateTime.now();
  CalendarController calendarController = new CalendarController();
  // Customer contacts
  final ScrollController scrollControllerContacts = new ScrollController();
  List<Customer> listCustomer = [];
  final int startingElements = 25;
  final int loadingElements = 10;
  bool canLoadMoreCustomer = true;

  WebCubit( this.route, CloudFirestoreService databaseRepository, Account account,) :
        _databaseRepository = databaseRepository, _account = account,
        super(LoadingWebCubitState()){
    if(route == Constants.homeRoute)
      loadMoreData(state.calendarDate, state.calendarDate);
    else
      emit(ReadyWebCubitState());
  }

  void loadMoreData([DateTime? start, DateTime? end]){
    DateTime from = TimeUtils.truncateDate(start??DateTime.now().subtract(new Duration(days: range)), "day");
    DateTime to = TimeUtils.truncateDate(end?.add(new Duration(days: 1))??(start??DateTime.now()).add(new Duration(days: range)), "day");
    _databaseRepository.subscribeEventsByOperator(_account.webops.map((operator) => operator.id).toList(), statusEqualOrAbove:  EventStatus.Refused,
          from: from, to: to).listen((eventsList) {
            evaluateEventsMap(eventsList);
    });
  }

  void evaluateEventsMap(List<Event> eventList){
    Map<String, List<Event>> eventsMap = {};
    _account.webops.forEach((operator) {
      List<Event> eventFiltered = eventList.where((event) =>
          [...event.suboperators.map((op) => op.id),event.operator?.id??""].contains(operator.id)).toList();
      eventsMap[operator.id] = eventFiltered;
    });
    emit(state.assign(calendarDate: newDate, eventsOpe: eventsMap));
  }

  void todayCalendarDate(){
    calendarController.setSelectedDay(DateTime.now());
    newDate = DateTime.now();
    loadMoreData(newDate, newDate);
  }

  void selectNextorPrevious(bool hasNext) {
    newDate = state.calendarDate;
    if(hasNext){
      newDate = newDate.add(Duration(days: 1));
    }else{
      newDate = newDate.subtract(Duration(days: 1));
    }
    calendarController.setSelectedDay(newDate);
    loadMoreData(newDate, newDate);
  }

  void updateAccount(List<Account> webOps) async {
    await _databaseRepository.updateAccountField(_account.id, "OperatoriWeb", webOps.map((webOp) => webOp.toWebDocument()));
    emit(state.assign(webops: _account.webops));
  }

  void removeAccount(String id) async {
    _account.webops.removeWhere((element) => element.id == id);
    List<Account> webOps = _account.webops;
    await _databaseRepository.updateAccountField(_account.id, "OperatoriWeb", webOps.map((webOp) => webOp.toWebDocument()));
    emit(state.assign(webops: _account.webops));
  }
  void showExpandedBox() {
    emit(state.assign(expandedMode:!state.expandedMode));
  }

  void selectCalendarDate(DateTime day){
    newDate = day;
    loadMoreData(day, day);
  }


  //FILTER CUSTOMER //
  Future<List<Customer>> onFiltersChanged(Map<String, FilterWrapper> filters) async {
    // Instead of do a basic repo get and evaluateEventsMap() the whole filtering process is handled directly in the query
    listCustomer = await _databaseRepository.getCustomersActiveFiltered(filters, limit: startingElements);
    canLoadMoreCustomer = listCustomer.length == startingElements;
    scrollToTheTop();
    emit(state.assign(filters: filters, customerList: listCustomer, filterCustomer: true));
    return state.customerList;
  }

  void scrollToTheTop(){
    if(scrollControllerContacts.hasClients)
      scrollControllerContacts.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 100),
      );
  }

  void resetFilterCustomer(){
    emit(state.assign( filterCustomer: false));
  }
}
