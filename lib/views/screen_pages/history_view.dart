/*
THIS IS THE MAIN PAGE OF THE OPERATOR
-l'appBar contiene menu a sinistra, titolo al centro
-in alto c'è una riga di giorni della settimana selezionabili
-(R)al centro e in basso c'è una grglia oraria dove sono rappresentati gli eventi dell'operatore corrente del giorno selezionato in alto
-(O)al centro e in basso c'è una grglia oraria dove sono rappresentati i propri eventi del giorno selezionato in alto
 */

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/cubit/history/history_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';
import 'package:venturiautospurghi/views/widgets/responsive_widget.dart';


class History extends StatefulWidget {
  final int selectedStatus;

  History([this.selectedStatus,Key key]) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState(selectedStatus);
}

class _HistoryState extends State<History> with TickerProviderStateMixin {
  final int selectedStatus;
  final List<MapEntry<Tab,int>> tabsHeaders = [
    MapEntry(new Tab(text: "TERMINATI",icon: Icon(Icons.flag),),Status.Ended),
    MapEntry(new Tab(text: "ELIMINATI",icon: Icon(Icons.delete),),Status.Deleted),
    MapEntry(new Tab(text: "RIFIUTATI",icon: Icon(Icons.assignment_late),),Status.Refused)
  ];

  _HistoryState(this.selectedStatus);

  @override
  Widget build(BuildContext context) {
    CloudFirestoreService repository = RepositoryProvider.of<
        CloudFirestoreService>(context);

    return new BlocProvider(
        create: (_) => HistoryCubit(repository, selectedStatus),
      child: ResponsiveWidget(
        smallScreen: _smallScreen(this,this.tabsHeaders),
        largeScreen: _largeScreen(this.tabsHeaders),
      ));
    }
}

class _largeScreen extends StatelessWidget {

  final List<MapEntry<Tab,int>> tabsHeaders;

  _largeScreen(this.tabsHeaders);

  @override
  Widget build(BuildContext context) {

    Account account = context.bloc<AuthenticationBloc>().account;

    return BlocBuilder <HistoryCubit, HistoryState>(
        builder: (context, state) {
          return !(state is HistoryReady) ? Center(child: CircularProgressIndicator()) : Container(
            height: MediaQuery.of(context).size.height,
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
                              onPressed: ()=> PlatformUtils.navigator(context, Constants.createEventViewRoute),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                        ...tabsHeaders.map((mapEntry)=>FlatTab(text: mapEntry.key.text, icon:(mapEntry.key.icon as Icon).icon, status: mapEntry.value, selectedStatus: state.selectedStatus)).toList()
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(height: 5,),
                        Text("Incarichi", style: title, textAlign: TextAlign.left,),
                        SizedBox(height: 5,),
                        (context.bloc<HistoryCubit>().state as HistoryReady).selectedEvents().length>0 ?
                            Container(
                              height: MediaQuery.of(context).size.height - 100,
                        child:GridView(
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 350.0,
                              mainAxisSpacing: 5.0,
                              crossAxisSpacing: 5.0,
                              childAspectRatio: 2.3,
                            ),
                            children: (context.bloc<HistoryCubit>().state as HistoryReady).selectedEvents().map((event)=>Container(
                                child: cardEvent(
                                  event: event,
                                  dateView: true,
                                  hourHeight: 120,
                                  gridHourSpan: 0,
                                  buttonArea: null,
                                  onTapAction: (event) => PlatformUtils.navigator(context, Constants.detailsEventViewRoute, event),
                                ))).toList()
                        )):Container(
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
          );
        });
  }

  Widget FlatTab({String text, IconData icon, int status, int selectedStatus}) {
    bool selected = status==selectedStatus;
    return  BlocBuilder <HistoryCubit, HistoryState>(
    buildWhen: (previous, current) =>
    previous.runtimeType != current.runtimeType,
    builder: (context, state) {
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
          onPressed: (){context.bloc<HistoryCubit>().onStatusSelect(status);},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(
              right: Radius.circular(15.0))),
        ),
      );
    });
  }
}
class _smallScreen extends StatelessWidget {

  TabController _tabController;
  final List<MapEntry<Tab,int>> tabsHeaders;

  _smallScreen(_HistoryState ticker,this.tabsHeaders){
    _tabController = new TabController(vsync: ticker, length: tabsHeaders.length);
  }

  @override
  Widget build(BuildContext context) {
    _tabController.addListener(() { context.bloc<HistoryCubit>().onStatusSelect(tabsHeaders[_tabController.index].value);});

    return Material(
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
                //onTap: (index) => context.bloc<HistoryCubit>().onStatusSelect(tabsHeaders[_tabController.index].value),
                isScrollable: true,
                unselectedLabelColor: black,
                labelStyle: title.copyWith(fontSize: 16),
                labelColor: black,
                indicatorColor: yellow,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: tabsHeaders.map((pair) => pair.key).toList(),
                controller: _tabController,
              ),
            ), !PlatformUtils.isMobile ?
            Container(height: MediaQuery.of(context).size.height - 150, child: _HistoryContent(_tabController,tabsHeaders),) :
            Expanded(
              child: _HistoryContent(_tabController,tabsHeaders),)
          ],
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {

  TabController _tabController;
  final List<MapEntry<Tab,int>> tabsHeaders;

  _HistoryContent(this._tabController, this.tabsHeaders);


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
    buildWhen: (previous, current) => previous != current,
    builder: (context, state) {
      return !(state is HistoryReady) ? Center(child: CircularProgressIndicator()) :
      TabBarView(
        controller: _tabController,
        children:
         tabsHeaders.map((e) =>  Padding(
            padding: EdgeInsets.all(15.0),
          child:(state as HistoryReady).events(e.value).length>0 ?
          ListView.separated(
            separatorBuilder: (context, index) => SizedBox(height: 10,),
            physics: BouncingScrollPhysics(),
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            itemCount: (state as HistoryReady).events(e.value).length,
            itemBuilder: (context, index){
              return Container(
                child: cardEvent(
                  event: (state as HistoryReady).events(e.value)[index],
                  dateView: true,
                  hourHeight: 120,
                  gridHourSpan: 0,
                  buttonArea: null,
                  onTapAction: (event) => PlatformUtils.navigator(context, Constants.detailsEventViewRoute, event),
                )
              );
            }):Container(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(bottom: 5) ,child:Text("Nessun incarico da mostrare",style: title,)),
              ],
            ),
          )
      ),).toList()
      );
    });
  }
}