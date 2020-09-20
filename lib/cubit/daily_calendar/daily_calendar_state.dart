part of 'daily_calendar_cubit.dart';

abstract class DailyCalendarState extends Equatable {
  Map<DateTime, List> eventsMap;
  DateTime selectedDay;
  double gridHourHeight = 0;
  int gridHourSpan = 0;

  DailyCalendarState(DateTime selectedDay, [Map<DateTime, List> eventsMap]) :
        this.eventsMap = eventsMap ?? Map(),
        this.selectedDay = selectedDay ?? TimeUtils.truncateDate(DateTime.now(), "day");

  @override
  List<Object> get props => [eventsMap.length, selectedDay, gridHourHeight, gridHourSpan];
}

class DailyCalendarLoading extends DailyCalendarState{
  DailyCalendarLoading([DateTime selectedDay]):super(selectedDay);
}

class DailyCalendarReady extends DailyCalendarState {

  List<Event> selectedEvents() => eventsMap[selectedDay] ?? [];

  DailyCalendarReady(Map eventsMap, DateTime selectedDay) : super(selectedDay, eventsMap) {
    //the verticalGridEvents need the events of the selectedDay ordered
    eventsMap[selectedDay]?.sort((a, b) => a.start.compareTo(b.start));
    _calculateGridDimensions();
  }

  void _calculateGridDimensions() {
    List<Event> selectedEvents =  eventsMap[selectedDay] ?? [];
    if (selectedEvents.length > 0) {
      if (selectedEvents.length == 1 &&
          selectedEvents[0].start.compareTo(selectedDay.add(Duration(hours: Constants.MIN_WORKTIME))) <= 0 &&
          selectedEvents[0].end.compareTo(selectedDay.add(Duration(hours: Constants.MAX_WORKTIME))) >= 0) {
        this.gridHourHeight = Constants.MIN_CALENDAR_EVENT_HEIGHT;
        gridHourSpan = 0;
      } else {

        //identify minimum duration's event
        int md = 4;
        selectedEvents.forEach((e) => {
          md = max(0, min(md.toInt(), (DailyCalendarCubit.maxDailyHour(e.end, selectedDay) - DailyCalendarCubit.minDailyHour(e.start, selectedDay)) ~/ 60))
        });
        if (md == 0) {
          gridHourHeight = Constants.MIN_CALENDAR_EVENT_HEIGHT * 2;
          gridHourSpan = 1;
        } else {
          int i = 0;
          while (md == (max(pow(2, i), md)))i++;
          md = (min(pow(2, i - 1), md));
          gridHourHeight = Constants.MIN_CALENDAR_EVENT_HEIGHT;
          gridHourSpan = md;
        }
      }
    } else {
      gridHourHeight = Constants.MIN_CALENDAR_EVENT_HEIGHT;
      gridHourSpan = 1;
    }
  }

}
