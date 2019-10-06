import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;

class Fab{
  final context;
  const Fab(this.context);

Widget FabChooser(String route, bool isSupervisor){
  if(route == global.Constants.detailsEventViewRoute){
    if(isSupervisor) {
      return FloatingActionButton(
        child: Icon(FontAwesomeIcons.clipboardList),
        onPressed: ()=>_showDialogFabSupervisor(),
        backgroundColor: dark,
      );
    }else {
      return FloatingActionButton(
        child: Icon(FontAwesomeIcons.phone),
        onPressed: ()=>_showDialogFabOperator(),
        backgroundColor: dark,
      );
    }
  }else{
    return null;
  }
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
                  margin: EdgeInsets.symmetric(vertical:5.0),
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Cancella", style: customLightTheme.textTheme.title.copyWith(color: white)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){},
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
                  margin: EdgeInsets.symmetric(vertical:5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Modifica", style: customLightTheme.textTheme.title.copyWith(color: white)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){},
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
                SizedBox(height: 65,)
              ],
            )
        );
      }
  );
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
                  margin: EdgeInsets.symmetric(vertical:5.0),
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Responsabile", style: customLightTheme.textTheme.title.copyWith(color: white)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){},
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
                  margin: EdgeInsets.symmetric(vertical:5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Ufficio", style: customLightTheme.textTheme.title.copyWith(color: white)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){},
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
                SizedBox(height: 65,)
              ],
            )
        );
      }
  );
}

}