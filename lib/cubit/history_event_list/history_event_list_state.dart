part of 'history_event_list_cubit.dart';

abstract class HistoryEventListState extends Equatable {
  final int selectedStatus;
  final Map<int, List<Event>> eventsMap;

  HistoryEventListState(int? selectedStatus, [Map<int, List<Event>>? eventsMap]):
      this.selectedStatus = selectedStatus ?? EventStatus.Ended,
      this.eventsMap = eventsMap ?? {};
  
  @override
  List<Object> get props => [selectedStatus, eventsMap[selectedStatus]!=null?eventsMap[selectedStatus]!.map((e) => e).join():""];


  HistoryReady assign({
    int? selectedStatus,
    Map<int, List<Event>>? eventsMap,
  }) =>
      HistoryReady(selectedStatus ?? this.selectedStatus, eventsMap ?? this.eventsMap);

}


class HistoryLoading extends HistoryEventListState{
  HistoryLoading(int? selectedStatus):super(selectedStatus);
}

class HistoryReady extends HistoryEventListState{

  List<Event> selectedEvents() => eventsMap[selectedStatus] ?? [];

  List<Event> events(int status) => (eventsMap[status] ?? []).reversed.toList() ;

  HistoryReady(int selectedStatus, Map<int, List<Event>> eventsMap) : super(selectedStatus,eventsMap) {
    eventsMap[selectedStatus]?.sort((a, b) => a.start.compareTo(b.start));
  }

}