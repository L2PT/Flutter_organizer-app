import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

part 'operator_list_state.dart';

class OperatorListCubit extends Cubit<OperatorListState> {
  final CloudFirestoreService _databaseRepository;
  List<Account> operators;

  OperatorListCubit(this._databaseRepository)
      : assert(_databaseRepository != null),
        super(LoadingOperators()){
    getAllOperators();
  }

  void getAllOperators() async {
    operators = await _databaseRepository.getOperators();
    emit(ReadyOperators(operators));
  }

  void onSearchNameChanged(String value) {
    if(state is ReadyOperators) {
      emit((state as ReadyOperators).assign(searchNameField: value, operators: operators));
    }
  }

  void onSearchDateChanged(DateTime value) async{
    DateTime newValue = value.add(new Duration(hours:state.searchTimeField.hour, minutes:state.searchTimeField.minute));
    if(state is ReadyOperators) {
      operators = await _databaseRepository.getOperatorsFree("", state.searchTimeField,state.searchTimeField.add(new Duration(minutes: Constants.WORKTIME_SPAN)));
      emit((state as ReadyOperators).assign(searchTimeField: newValue, operators: operators));
    } else state.searchTimeField = newValue;
  }

  void onSearchTimeChanged(DateTime value) async {
    DateTime newValue = TimeUtils.truncateDate(state.searchTimeField, "day").add(new Duration(hours: value.hour, minutes: value.minute));
    if(state is ReadyOperators) {
      operators = await _databaseRepository.getOperatorsFree("", state.searchTimeField,state.searchTimeField.add(new Duration(minutes: Constants.WORKTIME_SPAN)));
      emit((state as ReadyOperators).assign(searchTimeField: newValue, operators: operators));
    } else state.searchTimeField = newValue;
  }

  void showFiltersBox() {
    emit((state as ReadyOperators).assign(filterBoxState:!state.filtersBoxVisibile));
  }

}
