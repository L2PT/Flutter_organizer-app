/*
THIS IS THE MAIN PAGE OF THE OPERATOR
-l'appBar contiene menu a sinistra, titolo al centro
-in alto c'è una riga di giorni della settimana selezionabili
-(R)al centro e in basso c'è una grglia oraria dove sono rappresentati gli eventi dell'operatore corrente del giorno selezionato in alto
-(O)al centro e in basso c'è una grglia oraria dove sono rappresentati i propri eventi del giorno selezionato in alto
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queries/collections.dart';
import 'package:venturiautospurghi/bloc/events_bloc/events_bloc.dart';
import 'package:venturiautospurghi/bloc/backdrop_bloc/backdrop_bloc.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugin/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/view/splash_screen.dart';
import 'package:venturiautospurghi/view/widget/card_event_widget.dart';

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
    MapEntry(new Tab(text: "TERMINATI"),Status.Ended),
    MapEntry(new Tab(text: "RIFIUTATI"),Status.Refused),
    MapEntry(new Tab(text: "ELIMINATI"),Status.Deleted)
  ];
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
            BlocProvider.of<EventsBloc>(context).dispatch(FilterEventsByStatus(tabsHeaders[_tabController.index].value));
            ready = true;
          }else if(state is Filtered && ready){
            return Material(
              elevation: 12.0,
              borderRadius: new BorderRadius.only(
                  topLeft: new Radius.circular(16.0),
                  topRight: new Radius.circular(16.0)),
              child: Container(
                  child: Column(
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
                          onTap: (index)=>BlocProvider.of<EventsBloc>(context).dispatch(FilterEventsByStatus(tabsHeaders[_tabController.index].value)),
                          isScrollable: true,
                          unselectedLabelColor: dark,
                          labelStyle: title.copyWith(fontSize: 16),
                          labelColor: dark,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: tabsHeaders.map((pair)=>pair.key).toList(),
                          controller: _tabController,
                        ),
                      ),
                      Expanded(
                        child: new TabBarView(
                          controller: _tabController,
                          children: List.generate(tabsHeaders.length, (index)=>Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                      child:
                                      state.events.length>0?ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: state.events.length,
                                        itemBuilder: (context, index) =>
                                            _buildEventList(state.events[index]),):Container(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(padding: EdgeInsets.only(bottom: 5) ,child:Text("Nessun incarico da mostrare",style: title,)),
                                          ],
                                        ),
                                      )
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            );
          }
          return LoadingScreen();
        }
    );
  }

  //--EVENT LIST
  Widget _buildEventList(Event event) {
    return Container();
  }

}