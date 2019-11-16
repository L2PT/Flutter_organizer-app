import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/backdrop_bloc/backdrop_bloc.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/user.dart';

class Fab {
  final context;
  const Fab(this.context);

  Widget FabChooser(String route) {
    Account account = BlocProvider.of<AuthenticationBloc>(context).account;
    if (route == global.Constants.detailsEventViewRoute) {
      if (account.supervisor) {
        return Container(
            decoration: BoxDecoration(color: grey, shape: BoxShape.circle),
            child: Padding(
              padding: EdgeInsets.all(2),
              child: FloatingActionButton(
                child: Icon(Icons.event_note,size: 40),
                onPressed: () => _showDialogFabSupervisor(),
                backgroundColor: dark,
                elevation: 6,
              ),
            ));
      } else {
        return Container(
            decoration: BoxDecoration(
                color: grey, borderRadius: BorderRadius.circular(100)),
            child: Padding(
                padding: EdgeInsets.all(2),
                child: FloatingActionButton(
                  child: Icon(Icons.phone,size: 40,),
                  onPressed: () => _showDialogFabOperator(),
                  backgroundColor: dark,
                  elevation: 6,
                )));
      }
    } else if (route == global.Constants.dailyCalendarRoute) {
      if (account.supervisor) {
        return FloatingActionButton(
          child: Icon(Icons.add,size: 40,),
          onPressed: (){
            DateTime day = Utils.formatDate(BlocProvider.of<BackdropBloc>(context).day,"day");
            if(DateTime.now().isAfter(day)) day = Utils.formatDate(DateTime.now(), "day");
            day = day.add(Duration(hours: global.Constants.MIN_WORKHOUR_SPAN));
            Event ev = Event.empty();
            ev.start = day;
            ev.end = day.add(Duration(minutes: global.Constants.WORKHOUR_SPAN));
            Navigator.pushNamed(context, global.Constants.formEventCreatorRoute, arguments: ev);
          },
          backgroundColor: dark,
        );
      }
    }
    return null;
  }

  void _showDialogFabSupervisor() {
    showDialog(
        context: context,
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
                          onTap: () => Utils.deleteDialog(context),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dark,
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
                            style: customLightTheme.textTheme.title
                                .copyWith(color: white)),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(context, global.Constants.MODIFY_SIGNAL);
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dark,
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
  }

  void _showDialogFabOperator() {
    showDialog(
        context: context,
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
                            style: customLightTheme.textTheme.title
                                .copyWith(color: white)),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            _actionOperatoreCall(true);
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dark,
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
                            style: customLightTheme.textTheme.title
                                .copyWith(color: white)),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            _actionOperatoreCall(false);
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dark,
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
  }
  _actionOperatoreCall(bool callResponsabile) async {
    Navigator.pop(context);
    String url = "tel:";
    if(callResponsabile){
      url = url+"3333333333";
    }else{
      url = url+"4444444444";
    }
//    if(await canLaunch(url)){
//      launch(url);
//    }
  }
}
