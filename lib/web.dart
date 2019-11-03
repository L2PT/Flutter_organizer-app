@JS()
library jquery;
import 'dart:convert';

import 'package:fb_auth/fb_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/plugin/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/repository/operators_repository.dart';
import 'package:venturiautospurghi/view/details_event_view.dart';
import 'package:venturiautospurghi/view/form_event_creator_view.dart';
import 'package:venturiautospurghi/view/log_in_view.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:js/js.dart';
import 'package:venturiautospurghi/view/operator_selection_view.dart';
import 'package:venturiautospurghi/view/register_view.dart';
import 'package:venturiautospurghi/view/splash_screen.dart';
import 'bloc/authentication_bloc/authentication_bloc.dart';

final _auth = FBAuth();
final tabellaUtenti = 'Utenti';


/*------------------ DB -----------------------------*/

@JS()
external void initJs2Dart(dynamic data);

@JS()
external void login(String email);

@JS()
external void initCalendar();

@JS()
external dynamic cookieJar(String cookie, String value);

@JS()
external dynamic addResource(dynamic data);

@JS()
external dynamic deleteEvent(String id, dynamic event);

@JS()
external dynamic showAlert(String msg);

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
  external factory FullCalendar({method, date});
  external dynamic get method;
  external dynamic get date;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(//TOMAYBEDO inverti l'ordine del builder e del MaterialApp come in mobile.dart
      debugShowCheckedModeBanner: false,
      theme: customLightTheme,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Unauthenticated) {
            dynamic c = cookieJar("user", null);
            if(c != null && c != ""){
              Map<String, dynamic> map = jsonDecode(c);
              AuthUser u = AuthUser(uid: map["uid"],email: map["uid"],displayName: map["displayName"],isAnonymous: map["isAnonymous"],isEmailVerified: map["isEmailVerified"],);
              BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedIn(u));
              return SplashScreen();
            }
            jQuery("#calendar").html("");
            return LogIn();
          }else if (state is Authenticated) {
            cookieJar("user", '{"uid":"${state.user.id}","email":"${state.user.email}","displayName":"${state.user.name}","isAnonymous":"${state.user}","isEmailVerified":"${state.user}"}');
            return MyAppWeb(state.user, state.isSupervisor);
          }
          return SplashScreen();
        },
      ),
    );
  }
}
class MyAppWeb extends StatefulWidget {
  final Account account;
  final bool isSupervisor;
  const MyAppWeb(this.account, this.isSupervisor, {Key key}) : super(key: key);

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
    var formatter = new DateFormat('dddd D MMMM YYYY', 'it_IT');
    _dateCalendar = (jQuery('#calendar').children().length>0)?jQuery('#calendar').fullCalendar('getDate', null).format('dddd D MMMM YYYY').toString():formatter.format(DateTime.now()).toString();
    initJs2Dart(this);
    initCalendar();
    updateDateCalendar();
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
    if(widget.account!=null){
      if(widget.account.name!=null) {
        n = widget.account.name.toString();
      }
      if(widget.account.surname!=null) {
        c = widget.account.surname.toString().toUpperCase();
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
                              onPressed: (){
                                cookieJar("user", "");
                                BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedOut());
                              },
                            ),
                            Text(c, textAlign: TextAlign.right,style: title_rev),
                            SizedBox(width: 5,),
                            Text(n, textAlign: TextAlign.right,style: subtitle_rev),
                            SizedBox(width: 30),
                            FlatButton(
                                color: whiteoverlapbackground,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                onPressed: ()=>showDialogWindow("new_user", null),
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
                onPressed: ()=>showDialogWindow("new_event", BlocProvider.of<AuthenticationBloc>(context).user),
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
      case "event":{dialogContainer = DetailsEvent(PlatformUtils.EventFromMap(param.id, param.color, param));}break;
      case "new_event":{dialogContainer = EventCreator(getEventWithCurrentDay());}break;
      case "modify_event":{dialogContainer = EventCreator(PlatformUtils.EventFromMap(param.id, param.color, param));}break;
      case "new_user":{dialogContainer = Register();}break;
      case "add_operator":{dialogContainer = OperatorSelection(Event.empty(), false);}break;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Container(
            height:650, width:400,
            child: Scaffold(
                body: dialogContainer
            )
          ),
        );
      },
    ).then((onValue) async {
      jQuery('#wrap').css(CssOptions(zIndex: 1));
      if(onValue != null && onValue != false){
        switch(opt) {
          case "add_operator":{
            Event e = onValue as Event;
            //update local
            int i = 0;
            for(dynamic o in e.suboperators){
              Account a=Account.fromMap(e.idOperators[i++], o);
              a.webops=[];
              bool found = false;
              for(dynamic webop in widget.account.webops){
                Account b=Account.fromMap(null, webop);
                if (a.id == b.id){
                  found = true; break;
                }
              }
              if(!found) widget.account.webops.add(a.toMap());
            }
            //update firestore
            OperatorsRepository().updateOperator(widget.account.id, "OperatoriWeb", widget.account.webops);
            //update calendar js
            i = 0;
            addResource(e.suboperators.map((o){Account a=Account.fromMap(e.idOperators[i++], o);a.webops=[];return a;}).toList());
          }break;
          case "event":{
            if(onValue == global.Constants.DELETE_SIGNAL) {
              Event e = PlatformUtils.EventFromMap(param.id, param.color, param);
              e.status = Status.Deleted;
              deleteEvent(e.id, json.encode(e.toDocument(), toEncodable: myEncode));
//              jQuery('#calendar').fullCalendar('refetchEvents',null);
            }
            if(onValue == global.Constants.MODIFY_SIGNAL) {
              showDialogWindow("modify_event", param);
            }
          }break;
        }
      }
    });
  }

  void removeResource(dynamic res){
    dynamic j = null;
    for(dynamic o in widget.account.webops){
      if(Account.fromMap(null, o).id == res) j=o;
    }
    if(j!=null) widget.account.webops.remove(j);
    OperatorsRepository().updateOperator(widget.account.id, "OperatoriWeb", widget.account.webops);
  }

  Widget _buildTableCalendarWithBuilders(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: dark,
      ),
      body: TableCalendar(
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
      )
    );
  }


  void updateDateCalendar(){
    setState(() {
      _dateCalendar = jQuery('#calendar').fullCalendar('getDate', null).format('dddd D MMMM YYYY').toString();
    });
  }
  Event getEventWithCurrentDay(){
    DateTime day = DateTime.parse(jQuery('#calendar').fullCalendar('getDate', null).format('').toString()).add(Duration(hours: global.Constants.MIN_WORKHOUR_SPAN));
    Event event = Event.empty();
    event.start = day;
    event.end = day.add(Duration(minutes: global.Constants.WORKHOUR_SPAN));
    return event;
  }

  dynamic myEncode(dynamic item) {
    if(item is DateTime) {
      return item.toIso8601String();
    }
    if(item is Account) {
      return json.encode(item, toEncodable: myEncode);
    }
    return item.toString();
  }
}