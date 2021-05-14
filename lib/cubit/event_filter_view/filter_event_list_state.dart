part of 'filter_event_list_cubit.dart';

abstract class FilterEventListState extends Equatable {

  Map<String, FilterWrapper> filters = {};
  List<Event> listEventFiltered;

  FilterEventListState([Map<String, FilterWrapper>? filters, List<Event>? listEvent]):
        this.filters = filters??{},
        this.listEventFiltered = listEvent??[];

  List<Object?> get props => [this.listEventFiltered.map((e) => e.id).join()];

  ReadyFilterEventList assign({
    Map<String, FilterWrapper>? filters,
    List<Event>? eventsList,
  }) => ReadyFilterEventList(
    filters ?? this.filters,
    eventsList ?? this.listEventFiltered);

}

class LoadingFilterEventList extends FilterEventListState {}

class ReadyFilterEventList extends FilterEventListState {

  ReadyFilterEventList( Map<String, FilterWrapper> filters, List<Event> listEvent) : super(filters, listEvent);

}
