part of 'operators_bloc.dart';

@immutable
abstract class OperatorsEvent extends Equatable {
  OperatorsEvent([List props = const []]);
}

class LoadOperators extends OperatorsEvent {
  final dynamic subscription;
  final dynamic subscriptionArgs;

  LoadOperators (this.subscription, this.subscriptionArgs) : super([subscription,subscriptionArgs]);

  @override
  List<Object> get props => [subscription,subscriptionArgs];
}

class ApplyOperatorFilters extends OperatorsEvent {
  final String stringFilter;
  final DateTime dateFilter;

  ApplyOperatorFilters(this.stringFilter, this.dateFilter) : super([stringFilter, dateFilter]);

  @override
  List<Object> get props => [stringFilter, dateFilter];
}

class ApplyOperatorFilterString extends OperatorsEvent {
  final String stringFilter;

  ApplyOperatorFilterString(this.stringFilter) : super([stringFilter]);

  @override
  List<Object> get props => [stringFilter];
}

class ApplyOperatorFilterDate extends OperatorsEvent {
  final DateTime dateFilter;

  ApplyOperatorFilterDate(this.dateFilter) : super([dateFilter]);

  @override
  List<Object> get props => [];
}

class AddOperator extends OperatorsEvent {
  final Account user;

  AddOperator (this.user) : super([user]);

  @override
  List<Object> get props => [user];
}

class EventsUpdated extends OperatorsEvent {
  final List<Event> events;

  EventsUpdated(this.events);

  @override
  List<Object> get props => [events];
}

class Done extends OperatorsEvent {
  final List<Account> operators;

  Done(this.operators);

  @override
  List<Object> get props => [operators];
}