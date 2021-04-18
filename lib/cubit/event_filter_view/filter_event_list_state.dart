part of 'filter_event_list_cubit.dart';

abstract class FilterEventListState extends Equatable {

  List<Event> listEventFiltered;

  FilterEventListState([List<Event>? listEvent]):
    this.listEventFiltered = listEvent??[];

  List<Object?> get props => [this.listEventFiltered.map((e) => e.id).join()];

  ReadyEventFilterView assign({
    List<Event>? eventsList,
  }) =>
      ReadyEventFilterView(eventsList ?? this.listEventFiltered,);

}

class LoadingEventFilterView extends FilterEventListState {}

class ReadyEventFilterView extends FilterEventListState {

  List<Event> filteredEvent() => this.listEventFiltered;

  ReadyEventFilterView(List<Event>eventsList,) : super(eventsList);



}
