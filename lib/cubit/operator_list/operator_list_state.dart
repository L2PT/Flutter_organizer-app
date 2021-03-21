part of 'operator_list_cubit.dart';

abstract class OperatorListState extends Equatable {
  String searchNameField;
  DateTime searchTimeField;
  bool filtersBoxVisibile = false;

  OperatorListState([String? searchNameField, DateTime? searchTimeField]) :
        this.searchNameField = searchNameField ?? "",
        this.searchTimeField = searchTimeField ?? DateTime.now();
  
  @override
  List<Object> get props => [searchTimeField, searchTimeField, filtersBoxVisibile];
}

class LoadingOperators extends OperatorListState {
  
}

class ReadyOperators extends OperatorListState {
  List<Account> filteredOperators = [];

  ReadyOperators(List<Account> operators, {String? searchNameField, DateTime? searchTimeField}) : super(searchNameField, searchTimeField) {
    if(string.isNullOrEmpty(searchNameField))
      filteredOperators = [...operators];
    else
      operators.forEach((operator) {
        String searchedFields = operator.name + " " + operator.surname;
        if(searchedFields.toLowerCase().contains(searchNameField!.toLowerCase())){
          filteredOperators.add(operator);
        }
      });
  }

  @override
  List<Object> get props => [filteredOperators.map((op) => op.id).join(), searchNameField, searchTimeField, filtersBoxVisibile];

  ReadyOperators assign({
    required List<Account> operators,
    String? searchNameField,
    DateTime? searchTimeField,
    bool? filterBoxState,
  }) {
    return ReadyOperators(
        ((searchNameField == this.searchNameField || searchNameField == null || searchNameField.contains(this.searchNameField)) &&
        (this.searchTimeField == searchTimeField)) ? 
        this.filteredOperators : operators,
        searchNameField: searchNameField ?? this.searchNameField,
        searchTimeField: searchTimeField ?? this.searchTimeField
    )..filtersBoxVisibile = filterBoxState ?? this.filtersBoxVisibile;
  }
}