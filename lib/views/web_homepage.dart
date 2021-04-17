import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/cubit/messaging/messaging_cubit.dart';
import 'package:venturiautospurghi/cubit/web/web_cubit.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/repositories/firebase_messaging_service.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/views/widgets/splash_screen.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/web_bloc/web_bloc.dart';
import 'package:venturiautospurghi/web.dart';


class WebHomepage extends StatefulWidget {
  const WebHomepage({Key? key}) : super(key: key);

  @override
  _WebHomepageState createState() => _WebHomepageState();
}



class _WebHomepageState extends State<WebHomepage> with TickerProviderStateMixin {
  
  String getText(int status){
    switch(status){
      case EventStatus.Deleted: return "Eliminato";
      case EventStatus.Refused: return "Rifiutato";
      case EventStatus.New: return "Nuovo";
      case EventStatus.Delivered: return "Consegnato";
      case EventStatus.Seen: return "Visualizzato";
      case EventStatus.Accepted: return "Accettato";
      case EventStatus.Ended: return "Terminato";
      default: return "Nuovo";
    }
  }
  
  @override
  void initState() {
    super.initState();
    js.context['showDialogByContext_dart'] = this.showDialogByContext;
    js.context['eventStatusText_dart'] = EventStatus.getText;
    //TODO try to pass the [Constants] class
    init(Constants.debug, context.read<AuthenticationBloc>().account!.id);
    
  }

  void showDialogByContext(String dialogType, dynamic param) {
    PlatformUtils.navigator(context, dialogType, param);
  }

  @override
  Widget build(BuildContext context) {
    final CloudFirestoreService databaseRepository = context.read<CloudFirestoreService>();
    final FirebaseMessagingService messagingRepository = context.read<FirebaseMessagingService>();
    final Account account = context.select((AuthenticationBloc bloc)=>bloc.account!);
    
    MessagingCubit cubit = MessagingCubit(
        databaseRepository,
        messagingRepository,
        context.watch<AuthenticationBloc>().account!
    );
    js.context['updateAccontTokens_dart'] = cubit.updateAccountTokens;
    js.context['openEventDetails_dart'] = cubit.launchTheEvent;


    return new BlocProvider(
        create: (_) => WebCubit(databaseRepository, account),
        child: Scaffold(
            backgroundColor: Color(0x00000000),
            body: Stack(
              children: [
                BlocBuilder<WebBloc, WebState>(
                    buildWhen: (previous, current) => current is Ready,
                    builder: (context, state) {
                      if (state is Ready) {
                        return _buildWebPage();
                      } else context.read<WebCubit>().getDateCalendar(jQueryDate());
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
                    }),
                // this is not supported at the moment; messageHandlers and token request are made in javascript
                BlocProvider<MessagingCubit>.value(
                  value: cubit,
                  child: BlocListener<MessagingCubit, MessagingState>(
                    listener: (BuildContext context, MessagingState state) {
                      if(state.isWaiting())
                        if(context.read<WebBloc>().state.route == Constants.detailsEventViewRoute)
                          PlatformUtils.backNavigator(context);
                        PlatformUtils.navigator(context, Constants.detailsEventViewRoute, state.event);
                    }, child: Container(),)
                )
              ],
            )
        )
    );
  }
}

class _buildWebPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final Account account = context.read<AuthenticationBloc>().account!;

    Widget buttons = Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: <Widget>[
          Container(
            height: 50,
            width: 180,
            margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
            child: ElevatedButton(
                onPressed: () => PlatformUtils.navigator(context, Constants.createEventViewRoute),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add_box, color: white,),
                    SizedBox(width:5),
                    Text("Nuovo Incarico", style: button_card, textAlign: TextAlign.center,),
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
                      context.read<WebCubit>().getDateCalendar(jQueryDate());
                    },
                    icon: Icon(Icons.arrow_back_ios,color:grey_dark, size: 20,)
                ),
                IconButton(
                    onPressed: (){
                      jQuery('#calendar').fullCalendar('next',null);
                      context.read<WebCubit>().getDateCalendar(jQueryDate());
                    },
                    icon: Icon(Icons.arrow_forward_ios,color:grey_dark, size: 20,)
                ),SizedBox(width: 15,),
                BlocBuilder<WebCubit, WebCubitState>(
                    builder: (context, state) {
                      return Text(context.read<WebCubit>().state.calendarDate.toUpperCase(), style: title,);
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
                    child: ElevatedButton(
                        style: raisedButtonStyle.copyWith(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 25, vertical: 15)),
                        ),
                        onPressed: () => PlatformUtils.navigator(context, Constants.filterEventListRoute),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.search, color: white,),
                            SizedBox(width:5),
                            Text("Cerca interventi", style: subtitle_rev,),
                          ],
                        )
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
                    child: ElevatedButton(
                        style: raisedButtonStyle.copyWith(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 25, vertical: 15)),
                        ),
                        onPressed: (){
                          jQuery('#calendar').fullCalendar('today',null);
                          context.read<WebCubit>().getDateCalendar(jQueryDate());
                        },
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
                    child: ElevatedButton(
                        style: raisedButtonStyle.copyWith(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 25, vertical: 15),)),
                        onPressed: () => PlatformUtils.navigator(context, Constants.monthlyCalendarRoute),
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
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(border: Border(
                                  top: BorderSide(width: 4, color: black),
                                  bottom: BorderSide(
                                      color: context.read<WebBloc>().state.route == Constants.homeRoute?yellow:black,
                                      width: 4
                                  )
                              )),
                              child: TextButton(
                                onPressed: ()=>PlatformUtils.navigator(context, Constants.homeRoute),
                                child: Text("CALENDARIO INCARICHI",style: button_card),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(border: Border(
                                  top: BorderSide(width: 4, color: black),
                                  bottom: BorderSide(
                                      color: context.read<WebBloc>().state.route == Constants.historyEventListRoute?yellow:black,
                                      width: 4
                                  )
                              )),
                              child: TextButton(
                                onPressed: ()=>PlatformUtils.navigator(context, Constants.historyEventListRoute),
                                child: Text("STORICO",style: button_card),
                              ),
                            ),
                            Expanded(child: Container(),),
                            Container(
                              alignment: Alignment.centerRight,
                              child: Row(children: <Widget>[
                                IconButton(
                                  icon: FaIcon(FontAwesomeIcons.userTie, color: white),
                                  onPressed: (){},
                                ),
                                Text( account.surname.toUpperCase(), textAlign: TextAlign.right,style: title_rev),
                                SizedBox(width: 5,),
                                Text( account.name.toUpperCase(), textAlign: TextAlign.right,style: subtitle_rev),
                                SizedBox(width: 30),
                                TextButton(
                                    style: flatButtonStyle.copyWith(
                                        backgroundColor: MaterialStateProperty.all<Color>(whiteoverlapbackground),
                                        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 25, vertical: 15)),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),)
                                    ),
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
                                  icon: Icon(FontAwesomeIcons.doorOpen,),
                                  onPressed: (){
                                    context.read<AuthenticationBloc>().add(LoggedOut());
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

    if(context.read<WebBloc>().state.route == Constants.homeRoute){
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
                context.read<WebBloc>().state.content??Container()
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
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await showDialog( 
        barrierDismissible: Constants.debug,
        context: parentContext,
        builder: (BuildContext context) {
          parentContext.read<WebBloc>().dialogStack.add((parentContext.read<WebBloc>().state as DialogReady).callerContext);
          return RepositoryProvider<CloudFirestoreService>.value(
              value: RepositoryProvider.of<CloudFirestoreService>(parentContext),
              child: BlocProvider.value(
                  value: parentContext.read<WebBloc>(),
                  child: AlertDialog(
                    contentPadding: EdgeInsets.all(0),
                    content: Container(
                        height:655, width:400,
                        child: Scaffold(
                            body: parentContext.read<WebBloc>().state.content
                        )
                    ),
                  )
              ));
        },
      ).then((onValue) async {
        BuildContext caller = parentContext.read<WebBloc>().dialogStack.removeLast();
        if(parentContext.read<WebBloc>().dialogStack.length == 0) jQuery('#wrap').css(CssOptions(zIndex: 1));
        if(onValue != null && (!(onValue is bool) || onValue != false)){
          switch(parentContext.read<WebBloc>().state.route) {
            case Constants.monthlyCalendarRoute :{
              jQuery('#calendar').fullCalendar('gotoDate', onValue);
              parentContext.read<WebCubit>().getDateCalendar(jQueryDate());
            }break;
            case Constants.addWebOperatorRoute :{
              Event event = onValue as Event;
              Account account = parentContext.read<AuthenticationBloc>().account!;
              account.webops = event.suboperators;
              //update firestore and calendarJs
              parentContext.read<WebCubit>().updateAccount(account.webops)
                  .whenComplete((){jQuery('#calendar').fullCalendar("refetchResources", null);});
            }break;
            case Constants.operatorListRoute :{
              (parentContext.read<WebBloc>().state as DialogReady).callback?.call();
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