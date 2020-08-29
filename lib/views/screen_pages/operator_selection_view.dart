import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/cubit/operator_selection/operator_selection_cubit.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/views/widgets/list_tile_operator.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';

class OperatorSelection extends StatelessWidget {
  final Event _event;
  final bool requirePrimaryOperator;

  OperatorSelection(this._event, {this.requirePrimaryOperator = false});


  @override
  Widget build(BuildContext context) {
    var repository = RepositoryProvider.of<CloudFirestoreService>(context);

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: white,
      body: new BlocProvider(
          create: (_) => OperatorSelectionCubit(repository, _event, requirePrimaryOperator),
          child: _operatorSelectableList()
      ),
    );
  }
}

class _operatorSelectableList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    List<Widget> buildOperatorsList = (context.bloc<OperatorSelectionCubit>().state as ReadyOperators).operators.map((operator) => new ListTileOperator(
        operator,
        checkbox: context.bloc<OperatorSelectionCubit>().isTriState?2:1,
        isChecked: (context.bloc<OperatorSelectionCubit>().state as ReadyOperators).selectionList[operator.id],
        onTap: context.bloc<OperatorSelectionCubit>().onTap(operator))).toList();

    void onExit(bool out) {
      Navigator.pop(context, out);
    }

    return Scaffold(
        appBar: AppBar(
            title: Text('OPERATORI DISPONIBILI',style: title_rev,),
            leading: IconButton(icon:Icon(Icons.arrow_back, color: white),
              onPressed: () => onExit(false)
            )
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check, size: 40,),
          backgroundColor: black,
          onPressed:(){if(context.bloc<OperatorSelectionCubit>().validateAndSave()) onExit(true);},
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
            BlocBuilder<OperatorSelectionCubit, OperatorSelectionState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              return (state is ReadyOperators)? Expanded(
                child: ListView(
                    padding: new EdgeInsets.symmetric(vertical: 8.0),
                    children: buildOperatorsList),
              ):LoadingScreen();
            })
          ]
        )
      )
    );
  }
}