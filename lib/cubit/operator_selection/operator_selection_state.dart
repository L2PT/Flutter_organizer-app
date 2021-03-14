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

  ReadyOperators(this.operators, {Event? event}) {
    if(event != null) {
      operators.forEach((operator) { selectionList[operator.id] = 0; });
      event.suboperators.forEach((suboperator) {
        if(selectionList.containsKey(suboperator.id))
          selectionList[suboperator.id] = 1;
      });
      if(event.operator != null && selectionList.containsKey(event.operator!.id)) {
        selectionList[event.operator!.id] = 2;
        primaryOperatorSelected = true;
      }
    }
  }
  
  ReadyOperators.update(this.operators, this.selectionList, this.primaryOperatorSelected);

  ReadyOperators assign(Map<String, int> preSelectedList, bool primaryOperatorSelected) => ReadyOperators.update(
      this.operators,
      preSelectedList,
      primaryOperatorSelected);

  @override
  List<Object> get props => [operators, selectionList, primaryOperatorSelected];
}
