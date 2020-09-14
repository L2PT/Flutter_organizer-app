part of 'history_cubit.dart';

abstract class HistoryState extends Equatable {

  int selectedStatus;
  Map<int, List> eventsMap;

  HistoryState(int selectedStatus,   Map<int, List> eventsMap):
      this.selectedStatus = selectedStatus ?? -1,
      this.eventsMap = eventsMap ?? [];

  @override
  List<Object> get props => [selectedStatus,eventsMap];
}


class HistoryLoading extends HistoryState{
  HistoryLoading([int selectedDay,Map<int, List> eventsMap]):super(selectedDay,eventsMap);
}

class HistoryReady extends HistoryState{

  List<Event> selectedEvents() => eventsMap[selectedStatus] ?? [];

  HistoryReady(int selectedStatus, Map<int, List> eventsMap) : super(selectedStatus,eventsMap){
    eventsMap[selectedStatus]?.sort((a, b) => a.start.compareTo(b.start));
  }

}
