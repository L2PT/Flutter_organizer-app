part of 'web_cubit.dart';

class WebCubitState extends Equatable {

  DateTime calendarDate;
  List<Account> webops = [];
  bool expandedMode = true;
  bool filterCustomer = false;
  Map<String,List<Event>> eventsOpe = {};
  Map<String, FilterWrapper> filters = {};
  List<Customer> customerList = [];

  WebCubitState({ bool expandedMode = true, List<Account>? webops, DateTime? calendarDate, Map<String,List<Event>>? eventsOpe,
    Map<String, FilterWrapper>? filters, List<Customer>? customerList, bool filterCustomer = false}):
              this.calendarDate = calendarDate??DateTime.now(),
              this.expandedMode = expandedMode,
              this.filterCustomer = filterCustomer,
              this.webops = webops??[],
              this.eventsOpe = eventsOpe??{},
              this.customerList = customerList??[],
              this.filters = filters??{};

  @override
  List<Object?> get props => [ expandedMode, calendarDate,  webops, eventsOpe.entries, this.customerList.map((e) => e.id).join()];

  ReadyWebCubitState assign({
    bool? expandedMode,
    bool? filterCustomer,
    DateTime? calendarDate,
    List<Account>? webops,
    Map<String,List<Event>>? eventsOpe,
    Map<String, FilterWrapper>? filters,
    List<Customer>? customerList,
  }) => ReadyWebCubitState.update(
      expandedMode??this.expandedMode,filterCustomer??this.filterCustomer, calendarDate??this.calendarDate, webops??this.webops,
      eventsOpe??this.eventsOpe,filters??this.filters,customerList??this.customerList);

}

class LoadingWebCubitState extends WebCubitState{
  @override
  List<Object> get props => [];
}

class ReadyWebCubitState extends WebCubitState{


  ReadyWebCubitState([List<Account>? webops]): super(webops: webops);

  @override
  List<Object?> get props => [expandedMode, calendarDate,  webops, eventsOpe.entries, this.customerList.map((e) => e.id).join()];

  ReadyWebCubitState.update(bool expandedMode, bool filterCustomer, DateTime? calendarDate, List<Account> webops, Map<String,List<Event>> eventsOpe,
                          Map<String, FilterWrapper> filters,List<Customer> customerList):
        super(expandedMode: expandedMode, webops: webops, calendarDate: calendarDate, eventsOpe: eventsOpe, filters: filters, customerList: customerList,
      filterCustomer: filterCustomer);

  List<Event> selectedEventsOperator(String idOperator) {
    return eventsOpe[idOperator]??[];
  }

}