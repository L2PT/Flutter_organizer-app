part of 'customer_selection_cubit.dart';

abstract class CustomerSelectionState extends Equatable {
  String searchNameField;
  CustomerSelectionState([String? searchNameField,]):
        this.searchNameField = searchNameField ?? "";

  @override
  List<Object> get props => [searchNameField];

}

class LoadingCustomers extends CustomerSelectionState {
  @override
  List<Object> get props => [];
}

class ReadyCustomers extends CustomerSelectionState {
  List<Customer> filteredCustomers = [];
  late Event event;
  late Customer customer;

  ReadyCustomers(this.filteredCustomers, this.event, {String? searchNameField}): super(searchNameField){
    this.event.customer.name.isEmpty? this.customer = Customer.empty(): this.customer = this.event.customer;
  }

  ReadyCustomers.update(this.filteredCustomers, this.event,  String? searchNameField): super(searchNameField);

  ReadyCustomers assign({List<Customer>? filteredCustomers,Event? event,Customer? customer, String? searchNameField}) {
    var form = ReadyCustomers(filteredCustomers??this.filteredCustomers, event??this.event, searchNameField: searchNameField??this.searchNameField);
    form.customer = customer??this.customer;
    return form;
  }

  @override
  List<Object> get props => [filteredCustomers.map((op) => op.id).join(), event.toString(), customer.toString()];
}

