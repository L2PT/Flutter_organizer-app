import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:venturiautospurghi/models/customer.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/filter_wrapper.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';

part 'customer_contacts_state.dart';

class CustomerContactsCubit extends Cubit<CustomerContactsState> {
  final CloudFirestoreService _databaseRepository;
  final ScrollController scrollController = new ScrollController();
  List<Customer> listCustomer = [];
  final int startingElements = 25;
  final int loadingElements = 10;
  bool canLoadMore = true;
  Future<List<Customer>> Function(Map<String, FilterWrapper> filters) onFiltersChangedWeb = (Map<String, FilterWrapper> filters) async { return List<Customer>.empty(); };

  CustomerContactsCubit(this._databaseRepository, Map<String, dynamic> filters,
      //Future<List<Customer>> Function(Map<String, FilterWrapper> filters)? onFiltersChanged)
      //List<Customer> customerList
      ): super(LoadingCustomerContacts()){
      filters.keys.forEach((key) {
        state.filters[key]!.fieldValue = filters[key];
      });
      onFiltersChanged(state.filters);
  }

  void loadMoreData() async {
    listCustomer = List.from(state.customerList);
    listCustomer.addAll(await _databaseRepository.getCustomersActiveFiltered(state.filters, limit: loadingElements, startFrom: state.customerList.last.surname));
    canLoadMore = listCustomer.length == state.customerList.length+loadingElements;
    emit(state.assign(customerList: listCustomer));
  }

  Future<List<Customer>> onFiltersChanged(Map<String, FilterWrapper> filters) async {
    // Instead of do a basic repo get and evaluateEventsMap() the whole filtering process is handled directly in the query
    listCustomer = await _databaseRepository.getCustomersActiveFiltered(filters, limit: startingElements);
    canLoadMore = listCustomer.length == startingElements;
    scrollToTheTop();
    emit(state.assign(filters: filters, customerList: listCustomer));
    return listCustomer;
  }

  void scrollToTheTop(){
    if(scrollController.hasClients)
      scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 100),
      );
  }

  bool deleteCustomer(Customer customer){
    _databaseRepository.deleteCustomer(customer.id);
    List<Customer> filteredCustomers = List.of(state.customerList);
    filteredCustomers.removeWhere((element) => element.id == customer.id);
    emit(state.assign( customerList: filteredCustomers));
    return true;
  }

  Event getEventCustomer(Customer customer) {
    Event event = Event.empty();
    event.customer = customer;
    return event;
  }

  void updateCustomerList(List<Customer> customerList){
    emit(state.assign( customerList: customerList));
  }
}
