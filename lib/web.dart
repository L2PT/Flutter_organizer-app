@JS()
library jquery;
import 'dart:convert';
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/models/auth/authuser.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/plugin/firebase/firebase_auth_service.dart';
import 'package:venturiautospurghi/plugin/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/repository/operators_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/view/log_in_view.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:js/js.dart';
import 'package:venturiautospurghi/view/operator_selection_view.dart';
import 'package:venturiautospurghi/view/register_view.dart';
import 'package:venturiautospurghi/view/widget/loading_screen.dart';
import 'package:venturiautospurghi/view/widget/splash_screen.dart';
import 'bloc/authentication_bloc/authentication_bloc.dart';

@JS()
external void initCalendar();
external dynamic addResource(dynamic data);
external dynamic deleteEvent(String id, dynamic event);

@JS()
external dynamic WriteCookieJar(String cookie, String value);
external dynamic ReadCookieJar(String cookie);

@JS()
external dynamic consolLog(dynamic value);

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
  external factory CssOptions({backgroundColor, height, position, width, zIndex, display});
  external dynamic get backgroundColor; // properties based on jQuery api
  external dynamic get height;
  external dynamic get position;
  external dynamic get width;
  external dynamic get zIndex;
  external dynamic get display;
}
/*-------------------------------------------------*/

const String COOKIE_PATH = "user";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    var repository = RepositoryProvider.of<FirebaseAuthService>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: customLightTheme,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Unauthenticated) {
            String c = ReadCookieJar(COOKIE_PATH);
            if(!c.isNullOrEmpty()){
              Map<String, dynamic> map = jsonDecode(c);
              AuthUser u = AuthUser.fromMap(map);
              WriteCookieJar(COOKIE_PATH, "");
              repository.signInWithToken(u.email,u.token);
              return LoadingScreen();
            }
            jQuery("#calendar").html("");
            return LogIn();
          } else if (state is Authenticated) {
            if(!global.Constants.debug) WriteCookieJar(COOKIE_PATH, jsonEncode(state.user));
            return MyAppWeb();
          }
          return SplashScreen();
        },
      ),
    );
  }
}
class MyAppWeb extends StatefulWidget {
  const MyAppWeb({Key key}) : super(key: key);

  @override
  _MyAppWebState createState() => _MyAppWebState();
}

class _MyAppWebState extends State<MyAppWeb> with TickerProviderStateMixin{
  CalendarController _calendarController;
  String _dateCalendar;
  Account account;
  String selectedRoute;
  String userName;
  String userSurname;


  @override
  void initState() {
    super.initState();
    account = BlocProvider.of<AuthenticationBloc>(context).account;
    _calendarController = CalendarController();
    var formatter = new DateFormat('MMMM YYYY - ddd D', 'it_IT');
    _dateCalendar = (jQuery('#calendar').children().length>0)?jQuery('#calendar').fullCalendar('getDate', null).format('MMMM YYYY - ddd D',).toString():formatter.format(DateTime.now()).toString();
    js.context['showDialogByContext_dart'] = this.showDialogByContext;
    js.context['removeResource_dart'] = this.removeOperator;
    initCalendar();
    updateDateCalendar();
    userName = account?.name?.toString();
    userSurname = account?.surname?.toString()?.toUpperCase();
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
        body: Text("")
    );

  }

  Widget _buildPage(String route, dynamic content) {
    Widget navbar = Container(
        height: 50,
        child: Row(
          children: <Widget>[
            logo_web,
            SizedBox(width: 30),
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                        color: black,
                        borderRadius: BorderRadius.horizontal(left:Radius.circular(10.0))
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(border: Border(
                                  bottom: BorderSide(
                                      color: yellow,
                                      width: 3
                                  )
                              )),
                              child: FlatButton(
                                onPressed: ()=>{},
                                child: Text("CALENDARIO INCARICHI",style: button_card),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(border: Border(
                                  bottom: BorderSide(
                                      color: yellow,
                                      width: 3
                                  )
                              )),
                              child: FlatButton(
                                onPressed: ()=>{},
                                child: Text("STORICO",style: button_card),
                              ),
                            ),
                            Expanded(child: Container(),),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Row(children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.person, color: white),
                                ),
                                Text(userSurname, textAlign: TextAlign.right,style: title_rev),
                                SizedBox(width: 5,),
                                Text(userName, textAlign: TextAlign.right,style: subtitle_rev),
                                SizedBox(width: 30),
                                FlatButton(
                                    color: whiteoverlapbackground,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                    onPressed: ()=>showDialogByContext("new_user", null),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.person_add, color: white,),
                                        SizedBox(width:5),
                                        Text("CREA UTENTE", style: button_card,),
                                      ],
                                    )
                                ),
                                SizedBox(width: 20),
                                IconButton(
                                  icon: Icon(Icons.exit_to_app,),
                                  onPressed: (){
                                    WriteCookieJar("user", "");
                                    BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
                                  },
                                ),
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
    if(route == global.Constants.homeRoute){
      jQuery('#wrap').css(CssOptions(zIndex: 1));
      jQuery('#wrap').css(CssOptions(display: "block"));
      return Container(
          child:Column(
              children: <Widget>[
                navbar,
                buttons()
              ]
          )
      );
    }else{
      jQuery('#wrap').css(CssOptions(display: "none"));
      return Container(
          child:Column(
              children: <Widget>[
                navbar,
                content
              ]
          )
      );
    }
  }

  Widget buttons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: <Widget>[
          Container(
            height: 50,
            width: 180,
            margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
            child: RaisedButton(
                onPressed: ()=>{},
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.add_box, color: white,),
                    SizedBox(width:5),
                    Text("Nuovo Incarico", style: button_card,),
                  ],
                )
            ),
          ),
          Expanded(flex: 2,child: Container(),),
          Expanded(flex: 5,child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                    onPressed: (){
                      jQuery('#calendar').fullCalendar('prev',null);
                      updateDateCalendar();
                    },
                    icon: Icon(Icons.arrow_back_ios,color:grey_dark, size: 20,)
                ),
                IconButton(
                    onPressed: (){
                      jQuery('#calendar').fullCalendar('next',null);
                      updateDateCalendar();
                    },
                    icon: Icon(Icons.arrow_forward_ios,color:grey_dark, size: 20,)
                ),SizedBox(width: 15,),
                Text(_dateCalendar.toUpperCase(), style: title,)
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
                            Icon(Icons.today, color: white,),
                            SizedBox(width:5),
                            Text("Oggi", style: subtitle_rev,),
                          ],
                        )
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
                    child: RaisedButton(
                        onPressed: ()=>showDialogByContext("calendar", null),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.date_range, color: white,),
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

  void showDialogByContext(String dialogType, dynamic param) {
    // flutter defined function
    jQuery('#wrap').css(CssOptions(zIndex: -1));

    var dialogContainer;
    switch(dialogType) {
      case "calendar":{dialogContainer = _buildTableCalendarWithBuilders(context);}break;
      case "event":{
//        Map paramMap = json.decode(param);
//        dialogContainer = DetailsEvent(PlatformUtils.EventFromMap(paramMap["id"], paramMap["color"], paramMap));
        }break;
      case "new_event":{}break;
      case "modify_event":{
        Map paramMap = json.decode(param);}break;
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
              height:750, width:450,
              child: Scaffold(
                  body: dialogContainer
              )
          ),
        );
      },
    ).then((onValue) async {
      jQuery('#wrap').css(CssOptions(zIndex: 1));
      if(onValue != null && onValue != false){
        switch(dialogType) {
          case "add_operator":{
            Event e = onValue as Event;
            //update local
            int i = 0;
            for(Account o in e.suboperators){
              Account a= Account.empty();
              a.webops=[];
              bool found = false;
              for(dynamic webop in account.webops){
                Account b=Account.fromMap(null, webop);
                if (a.id == b.id){
                  found = true; break;
                }
              }
              if(!found) account.webops.add(a.toMap());
            }
            //update firestore
            OperatorsRepository().updateOperator(account.id, "OperatoriWeb", account.webops);
            //update calendar js
            i = 0;
            addResource(e.suboperators.map((o){Account a=Account.fromMap(e.idOperators[i++], o);a.webops=[];return a;}).toList());
          }break;
          case "event":{
            if(onValue == global.Constants.DELETE_SIGNAL) {
              Map paramMap = json.decode(param);
              Event e = PlatformUtils.EventFromMap(paramMap["id"], paramMap["color"], paramMap);
              e.status = Status.Deleted;
              deleteEvent(e.id, json.encode(e.toDocument(), toEncodable: myEncode));
//              jQuery('#calendar').fullCalendar('refetchEvents',null);
            }
            if(onValue == global.Constants.MODIFY_SIGNAL) {
              showDialogByContext("modify_event", param);
            }
          }break;
        }
      }
    });
  }

  void removeOperator(dynamic res){
    dynamic j = null;
    for(dynamic o in account.webops){
      if(Account.fromMap(null, o).id == res) j=o;
    }
    if(j!=null) account.webops.remove(j);
    OperatorsRepository().updateOperator(account.id, "OperatoriWeb", account.webops);
  }

  Widget _buildTableCalendarWithBuilders(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("CALENDARIO", style: title_rev,),
          backgroundColor: black,
        ),
        body: TableCalendar(
          rowHeight: 85,
          locale: 'it_IT',
          calendarController: _calendarController,
          initialCalendarFormat: CalendarFormat.month,
          formatAnimation: FormatAnimation.slide,
          startingDayOfWeek: StartingDayOfWeek.monday,
          availableGestures: AvailableGestures.none,
          availableCalendarFormats: {CalendarFormat.month: ''},
          onDaySelected: (date, events){
            jQuery('#calendar').fullCalendar('gotoDate',date.toLocal().toString());
            updateDateCalendar();
            Navigator.of(context).pop();},
          builders: CalendarBuilders(
            todayDayBuilder: (context, date, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 20),
                decoration: BoxDecoration(
                  color: grey_light,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Center(child:Text(
                    '${date.day}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333),fontSize: 18)
                ),
                ),
              );
            },
          ),
          headerStyle: HeaderStyle(
            leftChevronIcon:Icon(Icons.arrow_back_ios, color: black,),
            rightChevronIcon:Icon(Icons.arrow_forward_ios, color: black,),
          ),
        )








    );
  }



  ///UTILS

  void updateDateCalendar(){
    setState(() {
      _dateCalendar = jQuery('#calendar').fullCalendar('getDate', null).format('MMMM YYYY - ddd D').toString();
    });
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