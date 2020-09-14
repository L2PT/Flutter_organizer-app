import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';

part 'operator_list_state.dart';

class OperatorListCubit extends Cubit<OperatorListState> {
  final CloudFirestoreService _databaseRepository;
  List<Account> operators;

  OperatorListCubit(this._databaseRepository)
      : assert(_databaseRepository != null),
        super(LoadingOperators()){
    getOperators();
  }

  void getOperators() async {
    List<Account> operators = await _databaseRepository.getOperators();
    emit(ReadyOperators(operators));
  }

  void onSearchNameChanged(String value) {
    if(state is ReadyOperators) {
      emit((state as ReadyOperators).assign(searchNameField: value));
    }
  }

  void onSearchDateChanged(DateTime value) {
    if(state is ReadyOperators) {
      emit((state as ReadyOperators).assign(searchTimeField: value.add(
          Duration(hours:state.searchTimeField.hour, minutes:state.searchTimeField.minute)),
      operators: operators));
    }
  }

  void onSearchTimeChanged(DateTime value) async {
    if(state is ReadyOperators) {
      operators = await _databaseRepository.getOperatorsFree("", state.searchTimeField,state.searchTimeField.add(new Duration(minutes: Constants.WORKTIME_SPAN)));
      emit((state as ReadyOperators).assign(searchTimeField: TimeUtils.truncateDate(state.searchTimeField, "day").add(
          new Duration(hours: value.hour, minutes: value.minute)),
        operators: operators));
    }
  }

  void showFiltersBox() {
    state.filtersBoxVisibile = !state.filtersBoxVisibile;
    emit(state);
  }

}
