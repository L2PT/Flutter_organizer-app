import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugins/firebase/cloud_firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/views/widgets/fab_widget.dart';

part 'fab_state.dart';

class FabCubit extends Cubit<FabState> {
  FabCubit(this._databaseRepository, this._account, this._route)
      : assert(_databaseRepository != null && _account != null && _route != null),
        super(FabState(_route, _account.supervisor)) {
    if(state.isSupervisor) {
      if(state.route == global.Constants.detailsEventViewRoute) content = Fab_details_super();
      else if(state.route == global.Constants.dailyCalendarRoute) content = Fab_daily_super();
    } else {
      if(state.route == global.Constants.detailsEventViewRoute) content = Fab_details_oper();
    }
  }

  final CloudFirestoreService _databaseRepository;
  final Account _account;
  final String _route;
  Widget content = SizedBox();

  void callSupervisor() async {
    //TODO call here using the repository to get the number
    if(await canLaunch("")){
      launch("");
    }
  }

  void callOffice() async {
    //TODO call here using the repository to get the number
    if(await canLaunch("")){
      launch("");
    }
  }

}
