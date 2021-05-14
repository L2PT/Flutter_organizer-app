part of 'filter_events_cubit.dart';

enum _filterStatus { normal, loading }

class EventsFilterState extends Equatable {

  Map<String, FilterWrapper> filters = {};
  bool filtersBoxVisibile = false;
  _filterStatus status = _filterStatus.normal;

  EventsFilterState() {
    initFilter();
  }

  @override
  List<Object> get props => [filters.values.join(), filtersBoxVisibile, status];

  bool isLoading() => this.status == _filterStatus.loading;

  EventsFilterState.update(this.filters, this.filtersBoxVisibile, this.status);

  EventsFilterState assign({
    Map<String, FilterWrapper>? filters,
    bool? filtersBoxVisibile,
    _filterStatus? status,
  }) => new EventsFilterState.update(
      filters??this.filters,
      filtersBoxVisibile??this.filtersBoxVisibile,
      status??this.status);

  initFilter(){
    // maybe we can put the dbconstants strings
    filters = {
      "title": new FilterWrapper("title", null, (Event event, value) => value == null || event.title.toUpperCase().contains(value.toUpperCase()) ),
      "address" : new FilterWrapper("address", null, (Event event, value) => value == null || event.address.toUpperCase().contains(value.toUpperCase()) ),
      "phone" : new FilterWrapper("phone", null, (Event event, value) => value == null || event.customer.phone.toUpperCase().contains(value.toUpperCase()) ),
      "startDate" : new FilterWrapper("startDate", null, (Event event, value) => value == null || event.start.add(Duration(minutes: 1)).isAfter(value) ),
      "endDate" : new FilterWrapper("endDate", null, (Event event, value) => value == null || value.add(Duration(minutes: 1)).isAfter(event.end) ),
      "categories" : new FilterWrapper("categories", <String,bool>{}, (Event event, List<String>? value) =>
        value == null || value.any((category) => category == event.category)),
      "suboperators" : new FilterWrapper("suboperators", <Account>[], (Event event, List<Account>? value) {
        if(value == null) return true;
        List<String> idOperators = [...event.suboperators.map((op) => op.id),event.operator?.id??""];
        if(value.every((element) => idOperators.contains(element.id))) return true;
        return false;
    })};
  }



}