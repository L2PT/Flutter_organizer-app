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

  DailyCalendarReady(this.selectedDay,this.events);

  @override
  List<Object> get props => [selectedDay,events];
}
