part of 'event_filter_view_cubit.dart';

abstract class EventFilterViewState extends Equatable {

  List<Event> listEventFiltered;

  EventFilterViewState([List<Event>? listEvent]):
    this.listEventFiltered = listEvent??[];

  List<Object?> get props => [this.listEventFiltered.map((e) => e.id).join()];

  ReadyEventFilterView assign({
    List<Event>? eventsList,
  }) =>
      ReadyEventFilterView(eventsList ?? this.listEventFiltered,);

}

class LoadingEventFilterView extends EventFilterViewState {}

class ReadyEventFilterView extends EventFilterViewState {

  List<Event> filteredEvent() => this.listEventFiltered;

  ReadyEventFilterView(List<Event>eventsList,) : super(eventsList);



}
