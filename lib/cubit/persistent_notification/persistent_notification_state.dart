part of 'persistent_notification_cubit.dart';

class PersistentNotificationState extends Equatable {
  final List<Event> waitingEventsList;

  const PersistentNotificationState(this.waitingEventsList);

  @override
  List<Object> get props => [waitingEventsList];

}