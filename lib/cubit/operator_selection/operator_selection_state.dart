part of 'operator_selection_cubit.dart';

abstract class OperatorSelectionState extends Equatable {
  const OperatorSelectionState();
}

class LoadingOperators extends OperatorSelectionState {
  @override
  List<Object> get props => [];
}

class ReadyOperators extends OperatorSelectionState {
  List<Account> operators;
  Map<String,int> selectionList = Map();
  bool primaryOperatorSelected = false;

  ReadyOperators(this.operators, {Event event}) {
    if(event != null) {
      operators.forEach((operator) { selectionList[operator.id] = 0; });
      event.suboperators.forEach((suboperator) {
        if(selectionList.containsKey(suboperator.id))
          selectionList[suboperator.id] = 1;
      });
      if(event.operator != null && selectionList.containsKey((event.operator as Account).id)) {
        selectionList[(event.operator as Account).id] = 2;
        primaryOperatorSelected = true;
      }
    }
  }

  ReadyOperators.updateSelection(ReadyOperators state, Map<String, int> preSelectedList) {
    operators = state.operators;
    selectionList = preSelectedList;
    primaryOperatorSelected = state.primaryOperatorSelected;
  }

  @override
  List<Object> get props => [operators, selectionList, primaryOperatorSelected];
}
