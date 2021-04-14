import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

part 'operator_selection_state.dart';

class OperatorSelectionCubit extends Cubit<OperatorSelectionState> {
  final CloudFirestoreService _databaseRepository;
  final Event _event;
  final bool isTriState;
  late List<Account> operators;

  OperatorSelectionCubit(this._databaseRepository, Event? _event, this.isTriState) :
        this._event = _event ?? new Event.empty(),
        super(LoadingOperators()){
      getOperators();
  }

  void onTap(Account operator) {
    if(Constants.debug) print("${operator.name} ${operator.surname} selected");
    ReadyOperators state = (this.state as ReadyOperators);
    Map<String,int> selectionListUpdated = new Map.from(state.selectionList);
    if(selectionListUpdated.containsKey(operator.id)) {
      bool newFlag = state.primaryOperatorSelected;
      int newValue = (selectionListUpdated[operator.id]!+1) % ((isTriState && (!state.primaryOperatorSelected || state.primaryOperatorSelected && selectionListUpdated[operator.id] == 2))? 3 : 2);
      if(newValue == 2) newFlag = true;
      else if(newValue == 0 && newFlag) newFlag = false;
      selectionListUpdated[operator.id] = newValue;
      emit(state.assign(preSelectedList: selectionListUpdated, primaryOperatorSelected: newFlag));
    }
  }

  void getOperators() async {
    operators = await _databaseRepository.getOperatorsFree(_event.id, _event.start, _event.end);
    emit(new ReadyOperators(operators,event:_event));
  }

  void saveSelectionToEvent(){
    ReadyOperators state = (this.state as ReadyOperators);
    List<Account> tempOperators = state.filteredOperators;
    List<Account> subOperators = [];
    state.selectionList.forEach((key, value) {
      Account tempAccount = tempOperators.firstWhere((account) => account.id == key);
      if(value == 1) subOperators.add(tempAccount);
      else if(value == 2) _event.operator = tempAccount;
      tempOperators.remove(tempAccount);
    });
    _event.suboperators = subOperators;
  }

  bool validateAndSave() {
    if(!isTriState || (state as ReadyOperators).primaryOperatorSelected) {
      saveSelectionToEvent();
      return true;
    } else {
      PlatformUtils.notifyErrorMessage("Seleziona l'operatore principale, tappando due volte");
      return false;
    }
  }

  showFiltersBox(){}
  onSearchTimeChanged(DateTime date){}
  onSearchDateChanged(DateTime date){}

  onSearchNameChanged(String text){
    List<Account> filteredOperators = [];
    if(state is ReadyOperators) {
      if(string.isNullOrEmpty(text))
        filteredOperators = [...operators];
      else
        operators.forEach((operator) {
          String searchedFields = operator.name + " " + operator.surname;
          if(searchedFields.toLowerCase().contains(text.toLowerCase())){
            filteredOperators.add(operator);
          }
        });
      emit((state as ReadyOperators).assign(filteredOperators: filteredOperators));
    }
  }

  Event getEvent() => _event;
}