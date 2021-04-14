part of 'filter_event_cubit.dart';

enum _filterStatus { normal, loading }

class FilterEventState extends Equatable {

  Event eventFilter = Event.empty();
  bool filtersBoxVisibile = false;
  Map<String,bool> categorySelected =  Map();
  _filterStatus status = _filterStatus.normal;
  bool filterStartDate = false;
  bool filterEndDate = false;
  bool enableSearchField = true;

  FilterEventState({Event? eventFilter}){
    this.eventFilter = eventFilter ??  Event.empty();
  }

  bool isLoading() => this.status == _filterStatus.loading;

  @override
  List<Object> get props => [eventFilter, filtersBoxVisibile, categorySelected, status, filterEndDate,
    filterStartDate, enableSearchField];

  FilterEventState.update(this.eventFilter, this.categorySelected, this.filtersBoxVisibile,
      this.status, this.filterStartDate, this.filterEndDate, this.enableSearchField);

  FilterEventState assign({
    Event? eventFilter,
    Map<String,bool>? categorySelected,
    bool? filtersBoxVisibile,
    bool? enableSearchField,
    _filterStatus? status,
    bool? filterStartDate,
    bool? filterEndDate
  }) =>
      FilterEventState.update(
          eventFilter??this.eventFilter,
          categorySelected??this.categorySelected,
          filtersBoxVisibile??this.filtersBoxVisibile,
          status??this.status,
          filterStartDate??this.filterStartDate,
          filterEndDate??this.filterEndDate,
          enableSearchField??this.enableSearchField,
      );

}