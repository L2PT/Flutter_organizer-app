part of 'details_event_cubit.dart';

class DetailsEventState extends Equatable {
  const DetailsEventState(this.event);

  final Event event;

  @override
  List<Object> get props => [event];
}