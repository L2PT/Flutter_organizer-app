part of 'customer_filter_cubit.dart';

enum _filterStatus { normal, loading }

class CustomersFilterState extends Equatable {

  Map<String, FilterWrapper> filters = {};
  bool filtersBoxVisibile = false;
  bool isCompany = false;
  bool isPrivate = false;
  _filterStatus status = _filterStatus.normal;

  CustomersFilterState() {
    filters = FilterWrapper.initFilterCustomer();
  }

  @override
  List<Object> get props => [filters.values.join(), filtersBoxVisibile, status, isCompany, isPrivate];

  bool isLoading() => this.status == _filterStatus.loading;

  CustomersFilterState.update(this.filters, this.filtersBoxVisibile, this.status, this.isCompany, this.isPrivate);

  CustomersFilterState assign({
    Map<String, FilterWrapper>? filters,
    bool? filtersBoxVisibile,
    _filterStatus? status,
    bool? isCompany,
    bool? isPrivate,
  }) => new CustomersFilterState.update(
      filters??this.filters,
      filtersBoxVisibile??this.filtersBoxVisibile,
      status??this.status,
      isCompany??this.isCompany,
      isPrivate??this.isPrivate,
  );

}
