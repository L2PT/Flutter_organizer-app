part of 'customer_contacts_cubit.dart';

abstract class CustomerContactsState extends Equatable {
  Map<String, FilterWrapper> filters = {};
  final List<Customer> customerList;

  CustomerContactsState( [List<Customer>? customerList, Map<String, FilterWrapper>? filters]):
        this.customerList = customerList ?? [],
        this.filters = filters ?? {};

  @override
  List<Object> get props => [this.customerList.map((e) => e.id).join()];

  ReadyCustomerContacts assign({
    Map<String, FilterWrapper>? filters,
    List<Customer>? customerList,
  }) => ReadyCustomerContacts(
      filters ?? this.filters,
      customerList ?? this.customerList);
}

class LoadingCustomerContacts extends CustomerContactsState {}

class ReadyCustomerContacts extends CustomerContactsState {

  ReadyCustomerContacts( Map<String, FilterWrapper> filters, List<Customer> customerList) : super(customerList,filters);

}

