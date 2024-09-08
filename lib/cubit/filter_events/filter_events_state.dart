part of 'filter_events_cubit.dart';

enum _filterStatus { normal, loading }

class EventsFilterState extends Equatable {

  Map<String, FilterWrapper> filters = {};
  bool filtersBoxVisibile = false;
  _filterStatus status = _filterStatus.normal;

  EventsFilterState() {
    filters = FilterWrapper.initFilterEvent();
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

}