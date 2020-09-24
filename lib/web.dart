@JS()
library jquery;
import 'dart:convert';
import 'dart:js' as js;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/cubit/web/web_cubit.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_auth_service.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:js/js.dart';
import 'package:venturiautospurghi/views/screen_pages/log_in_view.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';
import 'package:venturiautospurghi/views/widgets/splash_screen.dart';
import 'bloc/authentication_bloc/authentication_bloc.dart';
import 'bloc/web_bloc/web_bloc.dart';
import 'cubit/create_event/create_event_cubit.dart';

@JS()
external void init(String idUtente);
external dynamic addResources(dynamic data);

@JS()
external dynamic WriteCookieJarJs(String cookie, String value);
external dynamic ReadCookieJarJs(String cookie);

@JS()
external dynamic showAlertJs(dynamic value);
external dynamic consoleLogJs(dynamic value);
external dynamic storageOpenUrlJs(dynamic value);
external Future<dynamic> storageGetFilesJs(dynamic value);
external dynamic storagePutFileJs(dynamic path, dynamic file);
external dynamic storageDelFileJs(dynamic value);

/*------------------- jQuery ----------------------------*/
//@JS("jQuery('#calendar').fullCalendar('today').format('dddd D MMMM YYYY')")
//external String today();

@JS()
class jQuery {
  external factory jQuery(String selector);
  external int get length;
  external jQuery html(String content);
  external jQuery hide();
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

String jQueryDate() => jQuery('#calendar').fullCalendar('getDate', null).format('MMMM YYYY - ddd D').toString();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    var authentication = RepositoryProvider.of<FirebaseAuthService>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: customLightTheme,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Unauthenticated) {
            String token = ReadCookieJarJs(COOKIE_PATH);
            if (!token.isNullOrEmpty()) {
              WriteCookieJarJs(COOKIE_PATH, "");
              authentication.signInWithToken(token);
              return LoadingScreen();
            }
            if(Constants.debug) context.repository<FirebaseAuthService>().signInWithEmailAndPassword( "giovanni.mimelli@gmail.com", "letstry", );
            jQuery("#calendar").hide();
            return LogIn();
          } else if (state is Authenticated) {
            var databaseRepository = context.bloc<AuthenticationBloc>().getRepository();
            if (!Constants.debug) WriteCookieJarJs(COOKIE_PATH, state.token);
            return RepositoryProvider.value(
              value: databaseRepository,
              child: BlocProvider(
                create: (context) {
                  return WebBloc(
                      account: context.bloc<AuthenticationBloc>().account,
                      databaseRepository: databaseRepository)..add(InitAppEvent());
                },
                child: MyAppWeb(),
              ));
          }
          return SplashScreen();
          },
      ),
    );
  }
}

//TODO move this to another file
class MyAppWeb extends StatefulWidget {
  const MyAppWeb({Key key}) : super(key: key);

  @override
  _MyAppWebState createState() => _MyAppWebState();
}

class _MyAppWebState extends State<MyAppWeb> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    js.context['showDialogByContext_dart'] = this.showDialogByContext;
    //TODO try to pass the [Constants] class
    init(context.bloc<AuthenticationBloc>().account.id);
  }

  void showDialogByContext(String dialogType, dynamic param) {
    PlatformUtils.navigator(context, dialogType, param);
  }

  @override
  Widget build(BuildContext context) {
    final CloudFirestoreService repository = RepositoryProvider.of<CloudFirestoreService>(context);
    final Account account = context.bloc<AuthenticationBloc>().account;

    return new BlocProvider(
        create: (_) => WebCubit(repository, account),
        child: Scaffold(
            backgroundColor: Color(0x00000000),
            body: Stack(
              children: [
                BlocBuilder<WebBloc, WebState>(
                    buildWhen: (previous, current) => current is Ready,
                    builder: (context, state) {
                      if (state is Ready) {
                        return _buildWebPage();
                      } else context.bloc<WebCubit>().getDateCalendar(jQueryDate());
                      return Container(
                        child: SplashScreen(),
                      );
                    }),
                BlocBuilder<WebBloc, WebState>(
                    buildWhen: (previous, current) => current is DialogReady,
                    builder: (context, state) {
                      if (state is DialogReady) {
                        _buildDialogWeb(context);
                      }
                      return Container();
                    })
              ],
            )
        )
    );
  }
}

class _buildWebPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Account account = context.bloc<AuthenticationBloc>().account;

    Widget buttons = Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: <Widget>[
          Container(
            height: 50,
            width: 180,
            margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
            child: RaisedButton(
                onPressed: () => PlatformUtils.navigator(context, Constants.createEventViewRoute),
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
                      context.bloc<WebCubit>().getDateCalendar(jQueryDate());
                    },
                    icon: Icon(Icons.arrow_back_ios,color:grey_dark, size: 20,)
                ),
                IconButton(
                    onPressed: (){
                      jQuery('#calendar').fullCalendar('next',null);
                      context.bloc<WebCubit>().getDateCalendar(jQueryDate());
                    },
                    icon: Icon(Icons.arrow_forward_ios,color:grey_dark, size: 20,)
                ),SizedBox(width: 15,),
                BlocBuilder<WebCubit, WebCubitState>(
                  builder: (context, state) {
                  return Text(context.bloc<WebCubit>().state.calendarDate.toUpperCase(), style: title,);
                })
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
                          context.bloc<WebCubit>().getDateCalendar(jQueryDate());
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
                        onPressed: () => PlatformUtils.navigator(context, Constants.monthlyCalendarRoute),
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
                                      color: BlocProvider.of<WebBloc>(context).state.route == Constants.homeRoute?yellow:black,
                                      width: 3
                                  )
                              )),
                              child: FlatButton(
                                onPressed: ()=>PlatformUtils.navigator(context, Constants.homeRoute),
                                child: Text("CALENDARIO INCARICHI",style: button_card),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(border: Border(
                                  bottom: BorderSide(
                                      color: BlocProvider.of<WebBloc>(context).state.route == Constants.historyEventListRoute?yellow:black,
                                      width: 3
                                  )
                              )),
                              child: FlatButton(
                                onPressed: ()=>PlatformUtils.navigator(context, Constants.historyEventListRoute),
                                child: Text("STORICO",style: button_card),
                              ),
                            ),
                            Expanded(child: Container(),),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Row(children: <Widget>[
                                IconButton(
                                  icon: FaIcon(FontAwesomeIcons.user, color: white),
                                  onPressed: (){},
                                ),
                                Text(account.surname?.toUpperCase(), textAlign: TextAlign.right,style: title_rev),
                                SizedBox(width: 5,),
                                Text(account.name, textAlign: TextAlign.right,style: subtitle_rev),
                                SizedBox(width: 30),
                                FlatButton(
                                    color: whiteoverlapbackground,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                    onPressed: ()=>PlatformUtils.navigator(context, Constants.registerRoute),
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
                                    WriteCookieJarJs(COOKIE_PATH, "");
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

    if(context.bloc<WebBloc>().state.route == Constants.homeRoute){
      jQuery('#wrap').css(CssOptions(zIndex: 1));
      jQuery('#wrap').css(CssOptions(display: "block"));
      return Container(
          child:Column(
              children: <Widget>[
                navbar,
                buttons,
              ]
          )
      );
    }else{
      jQuery('#wrap').css(CssOptions(display: "none"));
      return Container(
          child:Column(
              children: <Widget>[
                navbar,
                context.bloc<WebBloc>().state.content??Container()
              ]
          )
      );
    }
  }
}


class _buildDialogWeb extends StatelessWidget{

  final BuildContext parentContext;

  _buildDialogWeb(this.parentContext) {
    jQuery('#wrap').css(CssOptions(zIndex: -1));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
      context: parentContext,
      builder: (BuildContext context) {
          parentContext.bloc<WebBloc>().dialogStack.add((parentContext.bloc<WebBloc>().state as DialogReady).callerContext);
          return RepositoryProvider<CloudFirestoreService>.value(value: RepositoryProvider.of<CloudFirestoreService>(parentContext),
           child: BlocProvider.value(value: BlocProvider.of<WebBloc>(parentContext),
             child: AlertDialog(
               contentPadding: EdgeInsets.all(0),
               content: Container(
                   height:655, width:400,
                   child: Scaffold(
                       body: parentContext.bloc<WebBloc>().state.content
                   )
               ),
             )
           ));
      },
    ).then((onValue) async {
      BuildContext caller = parentContext.bloc<WebBloc>().dialogStack.removeLast();
      if(parentContext.bloc<WebBloc>().dialogStack.length == 0) jQuery('#wrap').css(CssOptions(zIndex: 1));
      if(onValue != null && (!(onValue is bool) || onValue != false)){
        switch(parentContext.bloc<WebBloc>().state.route) {
          case Constants.monthlyCalendarRoute :{
            jQuery('#calendar').fullCalendar('gotoDate', onValue);
            parentContext.bloc<WebCubit>().getDateCalendar(jQueryDate());
          }break;
          case Constants.addWebOperatorRoute :{
            Event event = onValue as Event;
            Account account = parentContext.bloc<AuthenticationBloc>().account;
            account.webops = event.suboperators??[];
            //update firestore and calendarJs
            parentContext.bloc<WebCubit>().updateAccount(account.webops)
                .whenComplete((){jQuery('#calendar').fullCalendar("refetchResources", null);});
          }break;
          case Constants.operatorListRoute :{
            caller.bloc<CreateEventCubit>().forceRefresh();
          }
        }
      }
    });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}