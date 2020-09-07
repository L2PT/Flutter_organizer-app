part of 'daily_calendar_cubit.dart';

abstract class DailyCalendarState extends Equatable {
  DailyCalendarState();
}

class DailyCalendarLoading extends DailyCalendarState{
  @override
  List<Object> get props => [];
}

class DailyCalendarReady extends DailyCalendarState {

  Map<DateTime, List> events;
  DateTime selectedDay;
  double gridHourHeight;
  int gridHourSpan;

  DailyCalendarReady(this.selectedDay,this.events){
    events[selectedDay].sort((a, b) => a.start.compareTo(b.start));
    List selectedEvents = events[selectedDay]  ?? [];
    if (selectedEvents.length > 0) {
      if (selectedEvents.length == 1 &&
          selectedEvents[0].start.compareTo(selectedDay.add(Duration(hours: Constants.MIN_WORKTIME))) <= 0 &&
          selectedEvents[0].end.compareTo(selectedDay.add(Duration(hours: Constants.MAX_WORKTIME))) >= 0) {
        this.gridHourHeight = Constants.MIN_EVENT_HEIGHT;
        gridHourSpan = 0;
      } else {

        //identify minimum duration's event
        int md = 4;
        selectedEvents.forEach((e) =>
        {
          md = max(0, min(md.toInt(), ((maxDailyHour(e.end) - minDailyHour(e.start)) / 60).toInt()))
        });
        if (md == 0) {
          gridHourHeight = Constants.MIN_EVENT_HEIGHT * 2;
          gridHourSpan = 1;
        } else {
          int i = 0;
          while (md == (max(pow(2, i), md)))i++;
          md = (min(pow(2, i - 1), md));
          gridHourHeight = Constants.MIN_EVENT_HEIGHT;
          gridHourSpan = md;
        }
      }
    } else {
      gridHourHeight = Constants.MIN_EVENT_HEIGHT;
      gridHourSpan = 1;
    }
  }

  @override
  List<Object> get props => [selectedDay,events,gridHourSpan,gridHourHeight];

  int minDailyHour(DateTime start) {
    return (start.day != selectedDay.day ? Constants.MIN_WORKTIME * 60 : max<int>(
        Constants.MIN_WORKTIME * 60, start.hour * 60 + start.minute));
  }

  int maxDailyHour(DateTime end) {
    return (end.day != selectedDay.day ? Constants.MAX_WORKTIME * 60 : min<int>(
        Constants.MAX_WORKTIME * 60, end.hour * 60 + end.minute));
  }

}
