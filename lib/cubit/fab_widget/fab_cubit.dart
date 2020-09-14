import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/views/widgets/fab_widget.dart';

part 'fab_state.dart';

class FabCubit extends Cubit<FabState> {
  FabCubit(this._context, this._databaseRepository, this._account, this._route)
      : assert(_databaseRepository != null && _account != null && _route != null),
        super(FabState(_route, _account.supervisor)) {
    if(state.isSupervisor) {
      if(state.route == Constants.detailsEventViewRoute) content = Fab_details_super(_context);
      else if(state.route == Constants.dailyCalendarRoute) content = Fab_daily_super();
    } else {
      if(state.route == Constants.detailsEventViewRoute) content = Fab_details_oper(_context);
    }
  }

  final BuildContext _context;
  final CloudFirestoreService _databaseRepository;
  final Account _account;
  final String _route;
  Widget content = SizedBox();

  void callSupervisor(Account supervisor) async {
    if(await canLaunch(supervisor.phone)){
      launch(supervisor.phone);
    }
  }

  void callOffice() async {
    String numUfficio = await _databaseRepository.getUfficio();
    if(await canLaunch(numUfficio)){
      launch(numUfficio);
    }
  }

}
