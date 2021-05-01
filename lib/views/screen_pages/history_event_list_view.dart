/*
THIS IS THE MAIN PAGE OF THE OPERATOR
-l'appBar contiene menu a sinistra, titolo al centro
-in alto c'è una riga di giorni della settimana selezionabili
-(R)al centro e in basso c'è una grglia oraria dove sono rappresentati gli eventi dell'operatore corrente del giorno selezionato in alto
-(O)al centro e in basso c'è una grglia oraria dove sono rappresentati i propri eventi del giorno selezionato in alto
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/cubit/history_event_list/history_event_list_cubit.dart';
import 'package:venturiautospurghi/models/event_status.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';
import 'package:venturiautospurghi/views/widgets/filter_events_widget.dart';
import 'package:venturiautospurghi/views/widgets/responsive_widget.dart';


class HistoryEventList extends StatefulWidget {
  final int? selectedStatus;

  HistoryEventList([this.selectedStatus,Key? key]) : super(key: key);

  @override
  _HistoryEventListState createState() => _HistoryEventListState(selectedStatus);
}

class _HistoryEventListState extends State<HistoryEventList> with TickerProviderStateMixin {
  final int? selectedStatus;
  final List<MapEntry<Tab,int>> tabsHeaders = [
    MapEntry(new Tab(text: "CONCLUSI",icon: Icon(Icons.flag),),EventStatus.Ended),
    MapEntry(new Tab(text: "ELIMINATI",icon: Icon(Icons.delete),),EventStatus.Deleted),
    MapEntry(new Tab(text: "RIFIUTATI",icon: Icon(Icons.assignment_late),),EventStatus.Refused)
  ];

  _HistoryEventListState(this.selectedStatus);

  @override
  Widget build(BuildContext context) {
    CloudFirestoreService repository = context.read<CloudFirestoreService>();

    return new BlocProvider(
        create: (_) => HistoryEventListCubit(repository, selectedStatus),
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

    return BlocBuilder <HistoryEventListCubit, HistoryEventListState>(
        builder: (context, state) {
          return !(state is HistoryReady) ? Center(child: CircularProgressIndicator()) : Container(
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
                          child: ElevatedButton(
                              onPressed: ()=> PlatformUtils.navigator(context, Constants.createEventViewRoute),
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
                        SizedBox(height: 10,),
                        ...tabsHeaders.map((mapEntry)=>FlatTab(text: mapEntry.key.text!, icon:(mapEntry.key.icon as Icon).icon!, status: mapEntry.value, selectedStatus: state.selectedStatus)).toList(),
                        EventsFilterWidget(
                          hintTextSearch: 'Cerca gli interventi',
                          clearFilter: context.read<HistoryEventListCubit>().clearFilter,
                          filterEvent:  context.read<HistoryEventListCubit>().filterHistoryEvent,
                          maxHeightContainerExpanded: MediaQuery.of(context).size.height-450,
                          isWebMode: true,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 5,),
                        Text("Tutti Gli Incarichi "+EventStatus.getCategoryText(state.selectedStatus), style: title, textAlign: TextAlign.left,),
                        SizedBox(height: 10,),
                        (context.read<HistoryEventListCubit>().state as HistoryReady).selectedEvents().length>0 ?
                            Container(
                              height: MediaQuery.of(context).size.height - 110,
                          child: GridView(
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 350.0,
                              mainAxisSpacing: 5.0,
                              crossAxisSpacing: 5.0,
                              childAspectRatio: 2.3,
                            ),
                            children: (context.read<HistoryEventListCubit>().state as HistoryReady).selectedEvents().map((event)=> Container(
                                child: CardEvent(
                                  event: event,
                                  dateView: true,
                                  height: 120,
                                  buttonArea: null,
                                  onTapAction: (event) => PlatformUtils.navigator(context, Constants.detailsEventViewRoute, event),
                                ))).toList()
                        )): Container(
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

  Widget FlatTab({required String text, required IconData icon, required int status, required int selectedStatus}) {
    bool selected = status==selectedStatus;
    return  BlocBuilder <HistoryEventListCubit, HistoryEventListState>(
    buildWhen: (previous, current) =>
    previous.runtimeType != current.runtimeType,
    builder: (context, state) {
      return Container(
        height: 45,
        child: TextButton(
          style: flatButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all<Color>(selected?black:whitebackground),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(15.0))),)
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color:selected?yellow:grey_dark, size: 35,),
              SizedBox(width: 5),
              Text("INCARICHI "+text, style: selected?button_card:subtitle),
            ],
          ),
          onPressed: (){context.read<HistoryEventListCubit>().onStatusSelect(status);},
        ),
      );
    });
  }
}

class _smallScreen extends StatelessWidget {

  late TabController _tabController;
  final List<MapEntry<Tab,int>> tabsHeaders;

  _smallScreen(_HistoryEventListState ticker, this.tabsHeaders){
    _tabController = new TabController(vsync: ticker, length: tabsHeaders.length);
  }

  @override
  Widget build(BuildContext context) {
    _tabController.addListener(() {
      context.read<HistoryEventListCubit>().onStatusSelect(tabsHeaders[_tabController.index].value);
    });

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
                //onTap: (index) => context.read<HistoryCubit>().onStatusSelect(tabsHeaders[_tabController.index].value),
                isScrollable: true,
                unselectedLabelColor: black,
                labelStyle: title.copyWith(fontSize: 16),
                labelColor: black,
                indicatorColor: yellow,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: tabsHeaders.map((pair) => pair.key).toList(),
                controller: _tabController,
              ),
            ),
          EventsFilterWidget(
            hintTextSearch: 'Cerca gli interventi',
            clearFilter: context.read<HistoryEventListCubit>().clearFilter,
            filterEvent:  context.read<HistoryEventListCubit>().filterHistoryEvent,
          ),
            !PlatformUtils.isMobile ?
            Container(height: MediaQuery.of(context).size.height - 150, child: _historyContent(_tabController,tabsHeaders),) :
            Expanded(
              child: _historyContent(_tabController,tabsHeaders),)
          ],
        ),
      ),
    );
  }
}

class _historyContent extends StatelessWidget {

  TabController _tabController;
  final List<MapEntry<Tab,int>> tabsHeaders;

  _historyContent(this._tabController, this.tabsHeaders);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryEventListCubit, HistoryEventListState>(
    buildWhen: (previous, current) => previous != current,
    builder: (context, state) {
      return !(state is HistoryReady) ? Center(child: CircularProgressIndicator()) :
      TabBarView(
        controller: _tabController,
        children:
         tabsHeaders.map((e) =>  Padding(
            padding: EdgeInsets.all(15.0),
          child:state.events(e.value).length>0 ?
          ListView.separated(
            separatorBuilder: (context, index) => SizedBox(height: 10,),
            physics: BouncingScrollPhysics(),
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            itemCount: state.events(e.value).length,
            itemBuilder: (context, index){
              return Container(
                child: CardEvent(
                  event: state.events(e.value)[index],
                  dateView: true,
                  height: 120,
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