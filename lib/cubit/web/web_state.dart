part of 'web_cubit.dart';

@immutable
class WebCubitState extends Equatable {
  const WebCubitState(this.calendarDate);

  final String calendarDate;

  @override
  List<Object> get props => [calendarDate];
}