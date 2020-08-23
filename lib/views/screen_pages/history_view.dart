/*
THIS IS THE MAIN PAGE OF THE OPERATOR
-l'appBar contiene menu a sinistra, titolo al centro
-in alto c'è una riga di giorni della settimana selezionabili
-(R)al centro e in basso c'è una grglia oraria dove sono rappresentati gli eventi dell'operatore corrente del giorno selezionato in alto
-(O)al centro e in basso c'è una grglia oraria dove sono rappresentati i propri eventi del giorno selezionato in alto
 */

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queries/collections.dart';
import 'package:venturiautospurghi/bloc/events_bloc/events_bloc.dart';
import 'package:venturiautospurghi/bloc/backdrop_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/plugin/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/view/form_event_creator_view.dart';
import 'file:///C:/Users/Gio/Desktop/Flutter_organizer-app/lib/views/widgets/splash_screen.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';
import 'package:venturiautospurghi/views/widgets/responsive_widget.dart';
//import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


//HANDLE cambia questa costante per modifcare la grandezza degli eventi
const double minEventHeight = 60.0;

class History extends StatefulWidget {
  History({Key key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> with TickerProviderStateMixin {
  TabController _tabController;
  final List<MapEntry<Tab,int>> tabsHeaders = [
    MapEntry(new Tab(text: "TERMINATI",icon: Icon(Icons.flag),),Status.Ended),
    MapEntry(new Tab(text: "ELIMINATI",icon: Icon(Icons.delete),),Status.Deleted),
    MapEntry(new Tab(text: "RIFIUTATI",icon: Icon(Icons.assignment_late),),Status.Refused)
  ];
  int selectedStatus = Status.Ended;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: tabsHeaders.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //MAIN BUILEDER METHOD
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          if (state is Loaded) {
            //get data
            BlocProvider.of<EventsBloc>(context).add(FilterEventsByStatus(tabsHeaders[_tabController.index].value));
            ready = true;
          }else if(state is Filtered && ready){
            Widget list=new TabBarView(
              controller: _tabController,
              children: List.generate(tabsHeaders.length, (index)=>Padding(
                  padding: EdgeInsets.all(15.0),
                  child: state.events.length>0?GridView(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 610.0,
                        mainAxisSpacing: 5.0,
                        crossAxisSpacing: 5.0,
                        childAspectRatio: 2.7,
                      ),
                      children: state.events.map((event)=>Container(
                          child: cardEvent(
                            e: event,
                            dateView: true,
                            hourHeight: 120,
                            hourSpan: 0,
                            buttonArea: false,
                            actionEvent: (ev)=> Utils.PushViewDetailsEvent(context, ev),
                          ))).toList()
                  ):Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(bottom: 5) ,child:Text("Nessun incarico da mostrare",style: title,)),
                      ],
                    ),
                  )
              ),
              ),
            );
            return ResponsiveWidget(
              smallScreen: Material(
                elevation: 12.0,
                borderRadius: new BorderRadius.only(
                    topLeft: new Radius.circular(16.0),
                    topRight: new Radius.circular(16.0)),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: whitebackground,
                            borderRadius: BorderRadius.all(
                                Radius.circular(30.0))),
                        child: new TabBar(
                          onTap: (index)=>BlocProvider.of<EventsBloc>(context).add(FilterEventsByStatus(tabsHeaders[_tabController.index].value)),
                          isScrollable: true,
                          unselectedLabelColor: black,
                          labelStyle: title.copyWith(fontSize: 16),
                          labelColor: black,
                          indicatorColor: yellow,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: tabsHeaders.map((pair)=>pair.key).toList(),
                          controller: _tabController,
                        ),
                      ),PlatformUtils.platform==Constants.web?
                      Container(height: MediaQuery.of(context).size.height-150, child: list,):
                      Expanded(child: list,)
                    ],
                  ),
                ),
              ),
              largeScreen: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child:Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 280,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 180,
                              margin: const EdgeInsets.symmetric(vertical:8.0, horizontal:16.0),
                              child: RaisedButton(
                                  onPressed: ()=>PlatformUtils.navigator(context, EventCreator(Utils.getEventWithCurrentDay(DateTime.now()))),
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
                            SizedBox(height: 20,),
                            Text("Archivi", style: title,),
                            ...tabsHeaders.map((mapEntry)=>FlatTab(text: mapEntry.key.text, icon:(mapEntry.key.icon as Icon).icon, status: mapEntry.value)).toList()
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 8,
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            SizedBox(height: 5,),
                            Text("Incarichi", style: title, textAlign: TextAlign.left,),
                            state.events.length>0?GridView(
                                shrinkWrap: true,
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 500.0,
                                  mainAxisSpacing: 5.0,
                                  crossAxisSpacing: 5.0,
                                  childAspectRatio: 2.8,
                                ),
                                children: state.events.map((event)=>Container(
                                    child: cardEvent(
                                      e: event,
                                      dateView: true,
                                      hourHeight: 120,
                                      hourSpan: 0,
                                      buttonArea: false,
                                      actionEvent: (ev)=> Utils.PushViewDetailsEvent(context, ev),
                                    ))).toList()
                            ):Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(bottom: 5) ,child:Text("Nessun incarico da mostrare",style: title,)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
          return LoadingScreen();
        }
    );
  }

  Widget FlatTab({String text, IconData icon, int status}) {
    bool selected = status==selectedStatus;
    return Container(
      height: 45,
      child: FlatButton(
        color: selected?black:whitebackground,
        child: Row(
          children: <Widget>[
            Icon(icon, color:selected?yellow:grey_dark, size: 35,),
            SizedBox(width: 5),
            Text("INCARICHI "+text, style: selected?button_card:subtitle),
          ],
        ),
        onPressed: (){selectedStatus=status; BlocProvider.of<EventsBloc>(context).add(FilterEventsByStatus(status));},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(
            right: Radius.circular(15.0))),
      ),
    );
  }

}