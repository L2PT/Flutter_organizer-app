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
  Map<String,int> selectionList = Map();
  bool primaryOperatorSelected = false;

  ReadyOperators(this.operators, {Event event, Map<String, int> preSelectedList}) {
    operators.forEach((operator) { selectionList[operator.id] = 0; });
    if(event != null) {
      event.suboperators.forEach((suboperator) {
        if(selectionList.containsKey((suboperator as Account).id))
          selectionList[(suboperator as Account).id] = 1;
      });
      if(event.operator != null && selectionList.containsKey((event.operator as Account).id)) {
        selectionList[(event.operator as Account).id] = 2;
        primaryOperatorSelected = true;
      }
    }
    if(preSelectedList != null) {
      preSelectedList.forEach((id, value) {
        if(selectionList.containsKey(id)) {
          selectionList[id] = value;
          if(value == 2)
            primaryOperatorSelected = true;
        }
      });
    }
  }

  @override
  List<Object> get props => [operators, selectionList, primaryOperatorSelected];
}
