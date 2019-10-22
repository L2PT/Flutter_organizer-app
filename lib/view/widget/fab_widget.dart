import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/view/form_event_creator_view.dart';

class Fab {
  final context;

  const Fab(this.context);

  Widget FabChooser(String route, bool isSupervisor) {
    if (route == global.Constants.detailsEventViewRoute) {
      if (isSupervisor) {
        return Container(
            decoration: BoxDecoration(color: grey, shape: BoxShape.circle),
            child: Padding(
              padding: EdgeInsets.all(2),
              child: FloatingActionButton(
                child: Icon(FontAwesomeIcons.clipboardList),
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
                  child: Icon(FontAwesomeIcons.phone),
                  onPressed: () => _showDialogFabOperator(),
                  backgroundColor: dark,
                  elevation: 6,
                )));
      }
    } else if (route == global.Constants.dailyCalendarRoute) {
      if (isSupervisor) {
        return FloatingActionButton(
          child: Icon(FontAwesomeIcons.plus),
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new EventCreator(null))),
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
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(
                                context, global.Constants.DELETE_SIGNAL);
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dark,
                            ),
                            child: Icon(FontAwesomeIcons.trashAlt),
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
                            Navigator.pop(
                                context, global.Constants.MODIFY_SIGNAL);
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dark,
                            ),
                            child: Icon(FontAwesomeIcons.pencilAlt),
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
                            child: Icon(FontAwesomeIcons.userTie),
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
                            child: Icon(FontAwesomeIcons.building),
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
  _actionOperatoreCall(bool callResponsabile) async*{
    Navigator.pop(context);
    String url = "tel:";
    if(callResponsabile){
      url = url+"3333333333";
    }else{
      url = url+"4444444444";
    }
    if(await canLaunch(url)){
      launch(url);
    }
  }
}
