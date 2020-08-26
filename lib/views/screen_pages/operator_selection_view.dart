import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/cubit/operator_selection_cubit.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/views/widgets/list_tile_operator.dart';
import 'package:venturiautospurghi/views/widgets/switch_widget.dart';

class OperatorSelection extends StatelessWidget {
  final Event _event;
  final bool supportPrimaryOperator;

  OperatorSelection(this._event, {this.supportPrimaryOperator = false});


  @override
  Widget build(BuildContext context) {
    var repository = RepositoryProvider.of<CloudFirestoreService>(context);
    var account = BlocProvider.of<AuthenticationBloc>(context).account;

    Widget content = Container();

    Widget loginPage = Container();

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: white,
      body: new BlocProvider(
          create: (_) => OperatorSelectionCubit(repository, _event, account),
          child: loginPage
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {

  List<Widget> buildOperatorsList = context.bloc<OperatorSelectionCubit>().operators.map((operator) => new ListTileOperator(
      operator,
      checkbox: context.bloc<OperatorSelectionCubit>().supportPrimaryOperator?2:1,
      isChecked: sel[operator],
      onTap: context.bloc<OperatorSelectionCubit>().onTap(operator))).toList();

    return Scaffold(
        appBar: AppBar(
            title: Text('OPERATORI DISPONIBILI',style: title_rev,),
            leading: IconButton(icon:Icon(Icons.arrow_back, color: white),
              onPressed:() => Navigator.pop(context, false),
            )
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check, size: 40,),
          backgroundColor: black,
          onPressed:(){if(!supportPrimaryOperator || superChecked)Navigator.pop(context, true);else
            return PlatformUtils.notifyErrorMessage("Seleziona l' operatore principale, tappando due volte");
          },
    ),
        body: Material(
        elevation: 12.0,
        borderRadius: new BorderRadius.only(
            topLeft: new Radius.circular(16.0),
            topRight: new Radius.circular(16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15.0),
            Padding(padding: EdgeInsets.only(left: 20), child: Text("Aggiungi gli operatori disponibili", style: label,)),
            Expanded(
              child: ListView(
                padding: new EdgeInsets.symmetric(vertical: 8.0),
                children: buildOperatorsList ),
            )
          ],
        )
      )
    );
  }
}