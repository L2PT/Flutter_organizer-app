import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/cubit/create_event/create_event_cubit.dart';
import 'package:venturiautospurghi/cubit/operator_selection/operator_selection_cubit.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/views/widgets/list_tile_operator.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';

class OperatorSelection extends StatelessWidget {
  BuildContext? callerContext;
  Event? event;
  final bool requirePrimaryOperator;

  OperatorSelection([this.event, this.requirePrimaryOperator = false, this.callerContext]);

  @override
  Widget build(BuildContext context) {
    if(callerContext != null) context = callerContext!;
    var repository = context.read<CloudFirestoreService>();

    return new Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: white,
      body: new BlocProvider(
          create: (_) => OperatorSelectionCubit(repository, event, requirePrimaryOperator),
          child: _operatorSelectableList()
      ),
    );
  }
}

class _operatorSelectableList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> buildOperatorsList() => (context.read<OperatorSelectionCubit>().state as ReadyOperators).operators.map((operator) => new ListTileOperator(
        operator,
        checkbox: context.read<OperatorSelectionCubit>().isTriState?2:1,
        isChecked: (context.read<OperatorSelectionCubit>().state as ReadyOperators).selectionList[operator.id]!,
        onTap: context.read<OperatorSelectionCubit>().onTap)).toList();

    void onExit(dynamic out) {
      Navigator.pop(context, out);
    }

    return Scaffold(
        appBar: AppBar(
            title: Text('OPERATORI LIBERI',style: title_rev,),
            leading: IconButton(icon:Icon(Icons.arrow_back, color: white),
              onPressed: () => onExit(false)
            ),
          actions: [
            Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(15.0),
            child: ElevatedButton(
              child: new Text('CONFERMA', style: subtitle_rev),
              style: raisedButtonStyle.copyWith(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0))),
              ),
              onPressed: (){
                if(context.read<OperatorSelectionCubit>().validateAndSave())
                  onExit(context.read<OperatorSelectionCubit>().getEvent());
              },
            )),
          ],
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
            Padding(padding: EdgeInsets.only(left: 20), child: Text("Scegli tra gli operatori disponibili", style: label,)),
            BlocBuilder<OperatorSelectionCubit, OperatorSelectionState>(
              buildWhen: (previous, current) => true,
              builder: (context, state) {
                return Expanded(
                  child: (state is ReadyOperators)? ListView(
                      padding: new EdgeInsets.symmetric(vertical: 8.0),
                      children: buildOperatorsList()) :
                  LoadingScreen()
                );
              })
          ]
        )
      )
    );
  }
}

