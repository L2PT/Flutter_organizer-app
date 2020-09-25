part of 'history_cubit.dart';

abstract class HistoryState extends Equatable {
  final int selectedStatus;
  final Map<int, List<Event>> eventsMap;

  HistoryState([int selectedStatus,   Map<int, List> eventsMap]):
      this.selectedStatus = selectedStatus ?? Status.Ended,
      this.eventsMap = eventsMap ?? {};

  @override
  List<Object> get props => [selectedStatus, eventsMap[selectedStatus]?.map((e) => e.id)?.join()];


  HistoryReady assign({int selectedStatus, Map<int, List<Event>> eventsMap}) =>
      HistoryReady(selectedStatus ?? this.selectedStatus, eventsMap ?? this.eventsMap);

}


class HistoryLoading extends HistoryState{
  HistoryLoading([int selectedStatus]):super(selectedStatus);
}

class HistoryReady extends HistoryState{

  List<Event> selectedEvents() => eventsMap[selectedStatus] ?? [];

  HistoryReady(int selectedStatus, Map<int, List<Event>> eventsMap) : super(selectedStatus,eventsMap) {
    eventsMap[selectedStatus]?.sort((a, b) => a.start.compareTo(b.start));
  }

}
