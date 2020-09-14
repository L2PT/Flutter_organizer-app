import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/details_event/details_event_cubit.dart';
import 'package:venturiautospurghi/cubit/fab_widget/fab_cubit.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/views/widgets/delete_alert.dart';

class Fab extends StatelessWidget {
  //TODO to test if the context must be passed from the parent
  @override
  Widget build(BuildContext context) {
    Account account = context.bloc<AuthenticationBloc>().account;
    String route = context.bloc<MobileBloc>().state.route;
    CloudFirestoreService repository = context.repository<CloudFirestoreService>();

    return new BlocProvider(
        create: (_) => FabCubit(context, repository, account, route),
        child: context.bloc<FabCubit>().content
    );
  }
}

class Fab_details_super  extends StatelessWidget {
  final BuildContext parentContext;

  Fab_details_super(this.parentContext);

  void _showDialogFabSupervisor() => showDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Container(
            padding: EdgeInsets.all(20.0),
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Cancella",
                          style: customLightTheme.textTheme.title
                              .copyWith(color: white)),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (await DeleteAlert(context).show()) {
                            Navigator.of(context).pop(); //fab
                            context.bloc<DetailsEventCubit>().modifyEvent();
                          }
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: black,
                          ),
                          child: Icon(Icons.delete,),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Modifica",
                          style: customLightTheme.textTheme.headline6
                              .copyWith(color: white)),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);//fab
                          context.bloc<DetailsEventCubit>().deleteEvent();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: black,
                          ),
                          child: Icon(Icons.edit),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 65,
                )
              ],
            ));
      });

  @override
  Widget build(BuildContext localContext) {
    return Container(
      decoration: BoxDecoration(color: grey, shape: BoxShape.circle),
      child: Padding(
        padding: EdgeInsets.all(2),
        child: FloatingActionButton(
          child: Icon(Icons.event_note,size: 40),
          onPressed: () => _showDialogFabSupervisor(),
          backgroundColor: black,
          elevation: 6,
        ),
    ));

  }

}

class Fab_details_oper extends StatelessWidget {

  final BuildContext parentContext;

  Fab_details_oper(this.parentContext);

  void _showDialogFabOperator() => showDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Container(
            padding: EdgeInsets.all(20.0),
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Responsabile",
                          style: customLightTheme.textTheme.headline6
                              .copyWith(color: white)),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          context.bloc<FabCubit>().callSupervisor(context.bloc<DetailsEventCubit>().state.event.operator);
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: black,
                          ),
                          child: Icon(Icons.supervised_user_circle),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Ufficio",
                          style: customLightTheme.textTheme.headline6
                              .copyWith(color: white)),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          context.bloc<FabCubit>().callOffice();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: black,
                          ),
                          child: Icon(Icons.business),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 65,
                )
              ],
            ));
      });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration( color: grey, borderRadius: BorderRadius.circular(100)),
      child: Padding(
        padding: EdgeInsets.all(2),
        child: FloatingActionButton(
          child: Icon(Icons.phone,size: 40,),
          onPressed: () => _showDialogFabOperator(),
          backgroundColor: black,
          elevation: 6,
        )
    ));
  }

}

class Fab_daily_super extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add,size: 40,),
      onPressed: (){
        Event ev = Event.empty();
        ev.start = TimeUtils.getNextWorkTimeSpan(DateTime.now());
        ev.end = TimeUtils.getNextWorkTimeSpan(ev.start);
        PlatformUtils.navigator(context, Constants.createEventViewRoute, ev);
      },
      backgroundColor: black,
    );
  }

}