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
  List<Account> filteredOperators;

  ReadyOperators(List<Account> operators, {String searchNameField, DateTime searchTimeField}) : super(searchNameField, searchTimeField) {
    operators.forEach((operator) {
      String nomeCognome = operator.name + " " + operator.surname;
      if(nomeCognome.contains(searchNameField)){
        //TODO manca il filtro per la data
        List<Account> operators = await _databaseRepository.getOperatorsFree(_event.id??"", _event.start, _event.end);
        filteredOperators.add(operator);
      }
    });
  }

  @override
  List<Object> get props => [filteredOperators, searchNameField, searchTimeField, filtersBoxVisibile];

  ReadyOperators assign({
    List<Account> operators,
    String searchNameField,
    DateTime searchTimeField,
  }) {
    return ReadyOperators((searchNameField.contains(this.searchNameField) &&
        (this.searchTimeField == searchTimeField) ? this.filteredOperators : operators),
        searchNameField: searchNameField ?? this.searchNameField,
        searchTimeField: searchTimeField ?? this.searchTimeField
    );
  }
}