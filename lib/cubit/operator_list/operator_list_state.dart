part of 'operator_list_cubit.dart';

abstract class OperatorListState extends Equatable {
  String searchNameField;
  DateTime searchTimeField;
  bool filtersBoxVisibile = false;

  OperatorListState([this.searchNameField = "", DateTime searchTimeField])
      : this.searchTimeField = searchTimeField ?? DateTime.now();
}

class LoadingOperators extends OperatorListState {
  LoadingOperators() : super();

  @override
  List<Object> get props => [searchTimeField, searchTimeField, filtersBoxVisibile];
}

class ReadyOperators extends OperatorListState {
  List<Account> filteredOperators = [];

  ReadyOperators(List<Account> operators, {String searchNameField, DateTime searchTimeField}) : super(searchNameField, searchTimeField) {
    operators.forEach((operator) {
      String nomeCognome = operator.name + " " + operator.surname;
      if(nomeCognome.contains(searchNameField??"")){
        filteredOperators.add(operator);
      }
    });
  }

  @override
  List<Object> get props => [filteredOperators?.map((op) => op.id)?.join(), searchNameField, searchTimeField, filtersBoxVisibile];

  ReadyOperators assign({
    List<Account> operators,
    String searchNameField,
    DateTime searchTimeField,
    bool filterBoxState,
  }) {
    return ReadyOperators(((searchNameField == this.searchNameField && searchNameField == null) ||
        (searchNameField??"").contains(this.searchNameField??"") &&
        (this.searchTimeField == searchTimeField) ? this.filteredOperators : operators),
        searchNameField: searchNameField ?? this.searchNameField,
        searchTimeField: searchTimeField ?? this.searchTimeField
    )..filtersBoxVisibile = filterBoxState ?? this.filtersBoxVisibile;
  }
}