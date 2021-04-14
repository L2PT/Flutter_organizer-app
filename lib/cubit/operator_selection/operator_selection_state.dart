part of 'operator_selection_cubit.dart';

abstract class OperatorSelectionState extends Equatable {
  String searchNameField;
  OperatorSelectionState([String? searchNameField,]):
        this.searchNameField = searchNameField ?? "";

  @override
  List<Object> get props => [searchNameField];

}

class LoadingOperators extends OperatorSelectionState {
  @override
  List<Object> get props => [];
}

class ReadyOperators extends OperatorSelectionState {
  Map<String,int> selectionList = Map();
  bool primaryOperatorSelected = false;
  List<Account> filteredOperators = [];

  ReadyOperators(this.filteredOperators, {String? searchNameField, Event? event}): super(searchNameField){
    if(event != null) {
      filteredOperators.forEach((operator) { selectionList[operator.id] = 0; });
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

  ReadyOperators.update(this.filteredOperators, this.selectionList, this.primaryOperatorSelected);

  ReadyOperators assign({List<Account>? filteredOperators, Map<String, int>? preSelectedList, bool? primaryOperatorSelected}) =>
      ReadyOperators.update(
      filteredOperators??this.filteredOperators,
      preSelectedList??this.selectionList,
      primaryOperatorSelected??this.primaryOperatorSelected);

  @override
  List<Object> get props => [filteredOperators.map((op) => op.id).join(), selectionList, primaryOperatorSelected];
}
