@JS()
library jquery;
import 'dart:async';

import 'package:fb_auth/fb_auth.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/plugin/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/view/log_in_view.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:js/js.dart';

import 'view/monthly_calendar_view.dart';

final _auth = FBAuth();
final tabellaUtenti = 'Utenti';

@JS("jQuery('#calendar').fullCalendar('today')")
external void today();

@JS()
class jQuery {
  external factory jQuery(String selector);
  external int get length;
  external jQuery css(CssOptions options);
  external jQuery fullCalendar(String a,String b);
}

@JS()
@anonymous
class FullCalendar {
  external factory FullCalendar(String method, String date);
}

@JS()
@anonymous
class CssOptions {
  external factory CssOptions({backgroundColor, height, position, width, zIndex});
  external dynamic get backgroundColor; // properties based on jQuery api
  external dynamic get height;
  external dynamic get position;
  external dynamic get width;
  external dynamic get zIndex;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = null;

  @override
  void initState() {
    _onLogin(null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: customLightTheme,
      home: MyAppWeb(isLoggedIn: _isLoggedIn,),
      routes: {
        //global.Constants.resetCodeRoute: (context) => ResetCode("1235"),
        global.Constants.logInRoute: (context) => LogIn(_onLogin),
      },
    );
  }

  /// Function to setup the user
  void _onLogin(AuthUser user) async {
    if(user == null){
      //check status and get role
      user = await _auth.currentUser();
      if(user == null){
        //go to the login page (you can't do it from here)
        setState(() {
          _isLoggedIn = false; //this tells the backdrop to navigate to login page
        });
        return;
      }else{
        setState(() {
          _isLoggedIn = true; //this tells the backdrop to navigate to login page
        });
      }
    }
//  //you are logged in, get role
//  QuerySnapshot documents = (await Firestore.instance.collection(tabellaUtenti).where('Email',isEqualTo: user.email).getDocuments());
//  for (DocumentSnapshot document in documents.documents) {
//    if(document != null) {
//      isSupervisor = document.data['Responsabile'];
//      setState(() {
//        _isSupervisor = isSupervisor;
//        _isLoggedIn = true; //this tells the backdrop to stop loading
//      });
//      break;
//    }
//  }
  }

  void _onLogout() async {
    await _auth.logout();
    Navigator.of(context).pushReplacementNamed(global.Constants.logInRoute);
  }

}

class MyAppWeb extends StatefulWidget {
  final bool isLoggedIn;

  const MyAppWeb({Key key,
    @required this.isLoggedIn
    }) : super(key: key);

  @override
  _MyAppWebState createState() => _MyAppWebState();
}

class _MyAppWebState extends State<MyAppWeb> with TickerProviderStateMixin{
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  void didUpdateWidget(MyAppWeb old) {
    super.didUpdateWidget(old);
    Timer.run(() {
    if (widget.isLoggedIn == false) {
      Navigator.of(context).pushReplacementNamed(global.Constants.logInRoute);
    }
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color(0x00000000),
          body:Container(
            child: Column(
              children: <Widget>[
                navbar(),
                buttons(),
              ],
            ),
          )
        );
  }

  Widget navbar() {
    return Container(
      //margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
      //padding: const EdgeInsets.only(top:16.0, right:16.0, bottom:4.0, left:16.0),
      height: 50,
      child: Row(
        children: <Widget>[
          logo_web,
          SizedBox(width: 30),
          Expanded(
            child: Container(
                decoration: BoxDecoration(
                    color: dark,
                    borderRadius: BorderRadius.horizontal(left:Radius.circular(10.0))
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                      children: <Widget>[
                        Text("CALENDARIO INCARICHI",style: title_rev),
                        Expanded(child: Container(),),
                        Container(
                          alignment: Alignment.bottomRight,
                          child: Row(children: <Widget>[
                            Icon(Icons.supervisor_account,),
                            Text("VENTURI ", textAlign: TextAlign.right,style: title_rev),
                            Text("Nicola", textAlign: TextAlign.right,style: subtitle_rev),
                            SizedBox(width: 30),
                            FlatButton(
                                color: whiteoverlapbackground,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                onPressed: (){},
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.person_add, color: white,),
                                    SizedBox(width:5),
                                    Text("CREA UTENTE", style: title_rev,),
                                  ],
                                )
                            )
                          ],
                          ),
                        ),
                      ]
                  ),
                )
              )
          ),
        ],
      )
    );
  }

  Widget buttons() {
      return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
            child: RaisedButton(
                onPressed: (){},
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.add_box, color: white,),
                    SizedBox(width:5),
                    Text("Nuovo Incarico", style: subtitle_rev,),
                  ],
                )
            ),
          ),
          Expanded(child: Container(),),
          Container(
              alignment: Alignment.bottomRight,
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
                    child: RaisedButton(
                        onPressed: (){
                          jQuery('#calendar').fullCalendar('today',null);
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.calendar_today, color: white,),
                            SizedBox(width:5),
                            Text("Oggi", style: subtitle_rev,),
                          ],
                        )
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
                    child: RaisedButton(
                        onPressed: _showDialog,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.calendar_view_day, color: white,),
                            SizedBox(width:5),
                            Text("Calendario", style: subtitle_rev,),
                          ],
                        )
                    ),
                  )
                ],
              )
          ),
        ],
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    jQuery('#wrap').css(CssOptions(zIndex: -1));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(contentPadding: EdgeInsets.all(0),content:Container(width:300,child:_buildTableCalendarWithBuilders(context)),
        );
      },
    ).then((onValue)=>jQuery('#wrap').css(CssOptions(zIndex: 1)));
  }

  Widget _buildTableCalendarWithBuilders(BuildContext context) {
    return TableCalendar(
      locale: 'it_IT',
      calendarController: _calendarController,
      availableGestures: AvailableGestures.none,
      onDaySelected: (date, events){
        jQuery('#calendar').fullCalendar('gotoDate',date.toLocal().toString());
        Navigator.of(context).pop();},
      headerStyle: HeaderStyle(
        leftChevronIcon:Icon(Icons.arrow_back_ios, color: dark,),
        rightChevronIcon:Icon(Icons.arrow_forward_ios, color: dark,),
      ),
    );
  }

}