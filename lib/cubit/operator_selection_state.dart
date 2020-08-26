part of 'operator_selection_cubit.dart';

abstract class OperatorSelectionState extends Equatable {
  const OperatorSelectionState();
}

class LoadingOperators extends OperatorSelectionState {
  @override
  List<Object> get props => [];
}

class ReadyOperators extends OperatorSelectionState {
  final List<Account> operators;

  const ReadyOperators(this.operators);

  @override
  List<Object> get props => [operators];
}
