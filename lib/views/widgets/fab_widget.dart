import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/details_event/details_event_cubit.dart';
import 'package:venturiautospurghi/cubit/fab_widget/fab_cubit.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/views/widgets/delete_alert.dart';

class Fab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Account account = context.read<AuthenticationBloc>().account!;
    String route = PlatformUtils.getRoute(context);
    CloudFirestoreService repository = context.read<CloudFirestoreService>();

    return new BlocProvider(
        create: (_) => FabCubit(context, repository, account, route),
        child: _fab()
    );
  }
}

class _fab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => context.select((FabCubit cubit)=>cubit.content);
}

class Fab_details_super  extends StatelessWidget {
  final BuildContext parentContext;

  Fab_details_super(this.parentContext);

  @override
  Widget build(BuildContext context) {
    return
      Container(
        decoration: BoxDecoration(color: grey, shape: BoxShape.circle),
        child: Padding(
          padding: EdgeInsets.all(2),
          child: FloatingActionButton(
            child: Icon(Icons.event_note,size: 40, color: white),
            onPressed: () => showDialog(
                context: parentContext,
                barrierDismissible: true,
                builder: (BuildContext dialogContext) {
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
                                    style: Theme.of(context).textTheme.headline6!
                                        .copyWith(color: white)),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if(await ConfirmCancelAlert(parentContext, title: "CANCELLA INCARICO", text: "Confermi la cancellazione dell'incarico?").show()) {
                                      Navigator.of(dialogContext).pop(); //fab
                                      context.read<DetailsEventCubit>().deleteEvent();
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: black,
                                    ),
                                    child: Icon(Icons.delete, color: white,),
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
                                    style: Theme.of(context).textTheme.headline6!
                                        .copyWith(color: white)),
                                SizedBox( width: 10, ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(dialogContext);//fab
                                    context.read<DetailsEventCubit>().modifyEvent();
                                  },
                                  child: Container(height: 50,width: 50,decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: black,
                                    ),
                                    child: Icon(Icons.edit, color: white),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox( height: 65)
                        ],
                      ));
                }),
            backgroundColor: black,
            elevation: 6,
          ),)
      );
  }

}

class Fab_details_oper extends StatelessWidget {

  final BuildContext parentContext;

  Fab_details_oper(this.parentContext);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration( color: grey, borderRadius: BorderRadius.circular(100)),
      child: Padding(
        padding: EdgeInsets.all(2),
        child: FloatingActionButton(
          child: Icon(Icons.phone,size: 40, color: white),
          onPressed: () =>  showDialog(
              context: parentContext,
              barrierDismissible: true,
              builder: (BuildContext dialogContext) {
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
                                  style: Theme.of(context).textTheme.headline6!
                                      .copyWith(color: white)),
                              SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                  context.read<FabCubit>().callSupervisor(context.select((DetailsEventCubit cubit)=>cubit.state.event.operator!.phone));
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: black,
                                  ),
                                  child: Icon(Icons.supervised_user_circle, color: white),
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
                                  style: Theme.of(context).textTheme.headline6!
                                      .copyWith(color: white)),
                              SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                  context.read<FabCubit>().callOffice();
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: black,
                                  ),
                                  child: Icon(Icons.business, color: white),
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
              }),
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
      child: Icon(Icons.add,size: 40, color: white),
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