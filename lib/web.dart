@JS()
library jquery;
import 'dart:async';

import 'package:fb_auth/fb_auth.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugin/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/view/details_event_view.dart';
import 'package:venturiautospurghi/view/log_in_view.dart';
import 'package:venturiautospurghi/bloc/backdrop_bloc/backdrop_bloc.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:js/js.dart';

final _auth = FBAuth();
final tabellaUtenti = 'Utenti';


/*------------------ DB -----------------------------*/

@JS()
external void initJs2Dart(dynamic data);

@JS()
external void login(String email);

@JS()
external void initCalendar();

/*------------------- jQuery ----------------------------*/
//@JS("jQuery('#calendar').fullCalendar('today').format('dddd D MMMM YYYY')")
//external String today();

@JS()
class jQuery {
  external factory jQuery(String selector);
  external int get length;
  external jQuery html(String content);
  external jQuery css(CssOptions options);
  external jQuery children();
  external jQuery fullCalendar(String a,String b);
  external jQuery format(String a);
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
/*-------------------------------------------------*/

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = null;
  dynamic _user = null;

  @override
  void initState() {
    _onLogin(null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: customLightTheme,
      home: MyAppWeb(isLoggedIn: _isLoggedIn, user: _user, actionLogOut: _onLogOut),
      routes: {
        //global.Constants.resetCodeRoute: (context) => ResetCode("1235"),
        global.Constants.logInRoute: (context) => LogIn(_onLogin,null),
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
        login(user.email);
        setState(() {
          _isLoggedIn = true; //this tells the backdrop to navigate to login page
          _user = user;
        });
      }
    }
  }

  void _onLogOut() async {
    _auth.logout();
    setState(() {
      _isLoggedIn = false; //this tells the backdrop to navigate to login page
      _user = null;
    });
    BlocProvider.of<BackdropBloc>(context).dispatch(NavigateEvent(global.Constants.logInRoute,null));
  }

}

class MyAppWeb extends StatefulWidget {
  final bool isLoggedIn;
  final dynamic user;
  final Function actionLogOut;

  const MyAppWeb({Key key,
    @required this.isLoggedIn,
    @required this.user,
    @required this.actionLogOut
    }) : super(key: key);

  @override
  _MyAppWebState createState() => _MyAppWebState();
}

class _MyAppWebState extends State<MyAppWeb> with TickerProviderStateMixin{
  CalendarController _calendarController;
  String _dateCalendar;
  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _dateCalendar = (jQuery('#calendar').children().length>0)?jQuery('#calendar').fullCalendar('getDate', null).format('dddd D MMMM YYYY').toString():"";
    initJs2Dart(this);
  }

  @override
  void didUpdateWidget(MyAppWeb old) {
    super.didUpdateWidget(old);
    Timer.run(() {
    if (widget.isLoggedIn == false) {
      jQuery("#calendar").html("");
      BlocProvider.of<BackdropBloc>(context).dispatch(NavigateEvent(global.Constants.logInRoute,null));
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
    String n = "",c ="";
    if(widget.user!=null && widget.user.displayName!=null){
      var s = widget.user.displayName.toString().split(" ");
      c = s[0].toString().toUpperCase();
      if(s.length>1){
        n = s[1].toString();
      }
    }
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
                            IconButton(
                              icon: Icon(Icons.supervisor_account,),
                              onPressed: (){widget.actionLogOut();},
                            ),
                            Text(c, textAlign: TextAlign.right,style: title_rev),
                            Text(n, textAlign: TextAlign.right,style: subtitle_rev),
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
          Expanded(child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 15,),
                IconButton(
                    onPressed: (){
                      jQuery('#calendar').fullCalendar('prev',null);
                      updateDateCalendar();
                    },
                    icon: Icon(Icons.arrow_back_ios,color:dark)
                ),
                IconButton(
                    onPressed: (){
                      jQuery('#calendar').fullCalendar('next',null);
                      updateDateCalendar();
                    },
                    icon: Icon(Icons.arrow_forward_ios,color:dark)
                ),SizedBox(width: 15,),
                Text(_dateCalendar, style: title,)
              ],
            ),
          ),),
          Container(
              alignment: Alignment.bottomRight,
              child: Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
                    child: RaisedButton(
                        onPressed: (){
                          jQuery('#calendar').fullCalendar('today',null);
                          updateDateCalendar();
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
                        onPressed: ()=>showDialogWindow("calendar", null),
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

  void showDialogWindow(String opt,dynamic param) {
    // flutter defined function
    jQuery('#wrap').css(CssOptions(zIndex: -1));
    var dialogContainer;
    switch(opt) {
      case "calendar":{dialogContainer = _buildTableCalendarWithBuilders(context);}break;
      case "event":{dialogContainer = DetailsEvent(event:Event.fromMap(param.id, param));}break;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(contentPadding: EdgeInsets.all(0),content:Container(width:300,child:dialogContainer),
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
        updateDateCalendar();
        Navigator.of(context).pop();},
      headerStyle: HeaderStyle(
        leftChevronIcon:Icon(Icons.arrow_back_ios, color: dark,),
        rightChevronIcon:Icon(Icons.arrow_forward_ios, color: dark,),
      ),
    );
  }


  void updateDateCalendar(){
    setState(() {
      _dateCalendar = jQuery('#calendar').fullCalendar('getDate', null).format('dddd D MMMM YYYY').toString();
    });
  }

}