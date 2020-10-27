import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';

part 'web_state.dart';

class WebCubit extends Cubit<WebCubitState> {
  final CloudFirestoreService _databaseRepository;
  final Account _account;

  WebCubit( CloudFirestoreService databaseRepository, Account account) :
        assert(databaseRepository != null && account != null),
        _databaseRepository = databaseRepository, _account = account,
        super((WebCubitState(DateFormat('MMMM YYYY - ddd D', 'it_IT').format(DateTime.now()).toString())));

  void getDateCalendar(String newDate) {
    emit(WebCubitState(newDate));
  }

  Future<void> updateAccount(List<Account> webOps) async {
    return await _databaseRepository.updateAccountField(_account.id, "OperatoriWeb", webOps.map((webOp) => webOp.toWebOpDocument()));
  }

}
