import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/views/screen_pages/operator_selection_view.dart';

part 'operator_selection_state.dart';

class OperatorSelectionCubit extends Cubit<OperatorSelectionState> {
  final CloudFirestoreService _databaseRepository;
  final Event _event;
  final Account _account;
  List<Account> operators;

  OperatorSelectionCubit(this._databaseRepository, this._event, this._account)
      : assert(_databaseRepository != null && _account != null),
        super(LoadingOperators()){
      getOperators();
  }



  bool onTap(Account op){
    print(sel[op]);
    setState(() {
      if(sel[op]==false) sel[op]=true;
      else if(sel[op]==true && !superChecked && widget.tristate){
        superChecked = true;
        sel[op]=null;
      }else{
        if(sel[op]==null) superChecked = false;
        sel[op]=false;
      }
    });
  }

  void getOperators() async {
    List<Account> operators = await _databaseRepository.getOperatorsFree(_event.id??"", _event.start, _event.end);
    emit(ReadyOperators(operators));
  }



  Event getOperatorsSelected(){
    //Input Object Account
    //Output Object Map
    List<String> selectedOperatorsId = [];
    List<dynamic> selectedSubOperators = [];
    Account selectedOperator = null;
    sel.keys.forEach((k){
      if(sel[k] == true){
        selectedOperatorsId.add(k.id);
        selectedSubOperators.add(k.toDocument());
      }else if(widget.supportPrimaryOperator && sel[k] == null){
        selectedOperatorsId.add(k.id);
        selectedOperator = k;
      }
    });
    if(widget.supportPrimaryOperator) {
      widget.event.idOperator = selectedOperator.id;
      widget.event.operator = selectedOperator.toDocument();
    }
    widget.event.idOperators = selectedOperatorsId;
    widget.event.suboperators = selectedSubOperators;
    return widget.event;
  }

  void getOperatorsDB() async {
    //Input Object Account
    //Output Object Map
    OperatorsRepository repo = OperatorsRepository();
    if(widget.supportPrimaryOperator)
      operators = await repo.getOperatorsFree(widget.event.id, widget.event.start, widget.event.end);
    else
      operators = await repo.getOperators();
    operators.forEach((operator){
      if(operator!=null) {
        if (widget.event.idOperator == operator.id) {
          sel[operator] = null;
          superChecked = true;
        }else if (widget.event.idOperators.contains(operator.id))
          sel[operator] = true;
        else
          sel[operator] = false;
      }
    });
    print(widget.event.idOperator);
    print(widget.event.idOperators);
    print(operators);
    setState(() {});
  }
}