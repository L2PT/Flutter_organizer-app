import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/views/widgets/dialog_app.dart';
import 'package:venturiautospurghi/views/widgets/fab_widget.dart';

class DetailsEvent extends StatefulWidget {
  final route = global.Constants.detailsEventViewRoute;
  Event event;

  DetailsEvent(
      @required this.event,{
        Key key,
      })  : assert(event != null),
        super(key: key);

  @override
  _DetailsEventState createState() => _DetailsEventState();
}

class _DetailsEventState extends State<DetailsEvent>
    with TickerProviderStateMixin {
  String textNamesOperators = "";
  String textStatusEvent = "";
  final double sizeIcon = 30;
  final double padding = 15.0;
  DateFormat formatterMese = new DateFormat('MMM', "it_IT");
  DateFormat formatterSett = new DateFormat('E', "it_IT");
  final List<Tab> tabsHeaders = <Tab>[
    new Tab(text: "DETTAGLIO"),
    new Tab(text: "DOCUMENTI"),
    new Tab(text: "NOTE")
  ];
  List<Widget> tabsContents = List();
  TabController _tabController;
  Color color = Color(global.Constants.fallbackColor);
  Account account;

  @override
  void initState() {
    super.initState();
    account = BlocProvider.of<AuthenticationBloc>(context).account;
    _tabController = new TabController(vsync: this, length: tabsHeaders.length);
    getColor();
    if(widget.event is String){
      //event coming from notification
    }
    if(widget.event.idOperator == account.id && widget.event.status < Status.Seen){
      EventsRepository().updateEvent(widget.event, "Stato", Status.Seen);
      widget.event.status = Status.Seen;
    }
    Account a = Account.fromMap(null, widget.event.operator);
    textNamesOperators += a.name+" "+a.surname+", ";
    widget.event.suboperators.forEach((operator){
      Account a = Account.fromMap(null,operator);
      textNamesOperators += a.name+" "+a.surname+", ";
    });
    textNamesOperators = textNamesOperators.trimRight();
    textNamesOperators = textNamesOperators.replaceRange(textNamesOperators.length-1, textNamesOperators.length, "");
    switch(widget.event.status) {
      case Status.New: textStatusEvent = "Nuovo"; break;
      case Status.Delivered: textStatusEvent = "Consegnato"; break;
      case Status.Seen: textStatusEvent = "Visualizzato"; break;
      case Status.Accepted: textStatusEvent = "Accettato"; break;
      case Status.Refused: textStatusEvent = "Rifiutato"; break;
      case Status.Ended: textStatusEvent = "Terminato"; break;
    }
    tabsContents = _buildTabsContents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _buildTabsContents() {
    List<Widget> t = List();
    DateFormat format = new DateFormat.Hm();
    String orarioStart = format.format(widget.event.start);
    String orarioEnd = format.format(widget.event.end);
    Widget detailsContent = ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.watch_later,
                      size: sizeIcon,
                    ),
                    SizedBox(
                      width: padding,
                    ),
                    Text(orarioStart + " - " + orarioEnd, style: subtitle_rev)
                  ],
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
                indent: 35,
                color: black_light,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.map,
                      size: sizeIcon,
                    ),
                    SizedBox(
                      width: padding,
                    ),
                    Text(widget.event.address.isEmpty?'Nessun indirizzo indicato':widget.event.address, style: subtitle_rev),
                    //Text(widget.event.address, style: subtitle_rev)
                  ],
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
                indent: 35,
                color: black_light,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.supervised_user_circle,
                      size: sizeIcon,
                    ),
                    SizedBox(
                      width: padding,
                    ),
                    Text(Account.fromMap(widget.event.idSupervisor, widget.event.supervisor).surname, style: subtitle_rev),
                    SizedBox(width: 5,),
                    Text(Account.fromMap(widget.event.idSupervisor, widget.event.supervisor).name, style: subtitle_rev),
                  ],
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
                indent: 35,
                color: black_light,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.assignment_ind,
                      size: sizeIcon,
                    ),
                    SizedBox(
                      width: padding,
                    ),
                    Text(textNamesOperators, style: subtitle_rev)
                  ],
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
                indent: 35,
                color: black_light,
              ),
              account.supervisor ? Column(
                  children: <Widget>[Container(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.work,
                              size: sizeIcon,
                            ),
                            SizedBox(
                              width: padding,
                            ),Text(textStatusEvent, style: subtitle_rev),]
                      )),Divider(
                    height: 2,
                    thickness: 2,
                    indent: 35,
                    color: black_light,
                  )]): Container(),Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.assignment,
                      size: sizeIcon,
                    ),
                    SizedBox(
                      width: padding,
                    ),
                    Container(
                      child: Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.event.description.isEmpty?'Nessuna nota indicata':widget.event.description.substring(0,min(widget.event.description.length,80)),
                              style: subtitle_rev,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),

                            SizedBox(height: 15),
                            widget.event.description.isNotEmpty?
                            GestureDetector(
                              child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: HexColor(widget.event.color),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 3, bottom: 3, left: 20, right: 20),
                                        child: Text(
                                          "LEGGI",
                                          style: subtitle_rev.copyWith(
                                              color: white),
                                        ),
                                      ))),
                              onTap: () => _tabController.animateTo(2),
                            ):Container()
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );

    Widget detailsDocument = Container(
        margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
        child: widget.event.documents!=""?ListView.separated(
            itemCount: (widget.event.documents!=null&&widget.event.documents.split("/").length>0)?widget.event.documents.split("/").length: 1,
            itemBuilder: (BuildContext context, int index) {
              final String fileName = widget.event.documents.split("/")[index];
              return new Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Row(children: <Widget>[
                  Icon(Icons.insert_drive_file, size: sizeIcon, color: black),
                  SizedBox(
                    width: padding,
                  ),
                  Container(
                    child: Text(fileName,
                      style: subtitle.copyWith(color: black, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.visible,
                    )
                  ),Expanded(child: Container(),),
                  IconButton(
                    icon:Icon(Icons.file_download, size: sizeIcon, color: black),
                    onPressed: () async {
                      var url = await PlatformUtils.storageGetUrl(widget.event.id+"/"+fileName);
                      PlatformUtils.download(url, fileName);
                    },
                  ),
                ])
              );
            },
          separatorBuilder: (BuildContext context, int index){return SizedBox(height: 10.0,);}
        ):ListView(physics: BouncingScrollPhysics(), children: <Widget>[Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Row(children: <Widget>[
            Icon(
              Icons.insert_drive_file,
              size: sizeIcon,
              color: black,
            ),
            SizedBox(
              width: padding,
            ),
            Container(
              child: Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Nessun documento allegato",
                        style: subtitle.copyWith(
                            color: black, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.visible,
                      )
                    ],
                  )),
            )
          ]),
        )
      ])
    );

    Widget detailsNote = Container(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.assignment,
                    size: sizeIcon,
                  ),
                  SizedBox(
                    width: padding,
                  ),
                  new Expanded(
                      flex: 1,
                      child: new SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: new Text(widget.event.description.isEmpty?'Nessuna nota indicata':widget.event.description, style: subtitle_rev),
                      ))
                ],
              ),
            ),
          ],
        ));

    t.add(detailsContent);
    t.add(detailsDocument);
    t.add(detailsNote);
    return t;
  }

  //MAIN BUILEDER METHODS
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('INTERVENTO'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: white),
              onPressed: () => Navigator.pop(context, false),
            )),
        floatingActionButton: widget.event.end.isBefore(DateTime.now())&&account.supervisor?Container(
            decoration: BoxDecoration(
                color: grey, borderRadius: BorderRadius.circular(100)),
            child: Padding(
                padding: EdgeInsets.all(2),
                child: FloatingActionButton(
                  child: Icon(Icons.delete, size: 40,),
                  onPressed: () => Utils.deleteDialog(context),
                  backgroundColor: black,
                  elevation: 6,
                ))):Fab(context).FabChooser(widget.route),
        body: Material(
            elevation: 12.0,
            child: Stack(children: <Widget>[
              Container(
                  child: Column(children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: Row(children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Container(color: black),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(color: HexColor(widget.event.color)),
                        )
                      ]),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(color: grey),
                    )
                  ])),
              Container(
                  child: Column(children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          color: HexColor(widget.event.color),
                          borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(30.0))),
                      child: Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 50,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: black,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(25.0))),
                              width: 55,
                              height: 100,
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                    child: Text(
                                        formatterMese
                                            .format(widget.event.start)
                                            .toUpperCase(),
                                        style: title_rev.copyWith(fontSize: 16)),
                                  ),
                                  Center(
                                    child: Text("${widget.event.start.day}",
                                        style: title_rev.copyWith(
                                            fontSize: 16)),
                                  ),
                                  Center(
                                    child: Text(
                                        formatterSett.format(widget.event.start),
                                        style: title_rev.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal)),
                                  )
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(widget.event.title.toUpperCase(),
                                    style: title),
                                Text(widget.event.category.toUpperCase(),
                                    style: subtitle.copyWith(color: black)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: black,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(40.0))),
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
                                      isScrollable: true,
                                      unselectedLabelColor: black,
                                      labelStyle: title.copyWith(fontSize: 16),
                                      labelColor: black,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      indicator: new BubbleTabIndicator(
                                        indicatorHeight: 40.0,
                                        indicatorColor:
                                        HexColor(widget.event.color),
                                        tabBarIndicatorSize:
                                        TabBarIndicatorSize.tab,
                                      ),
                                      tabs: tabsHeaders,
                                      controller: _tabController,
                                    ),
                                  ),
                                  Expanded(
                                    child: new TabBarView(
                                      controller: _tabController,
                                      children: tabsContents.map((Widget tab) {
                                        return tab;
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 150,
                            decoration: BoxDecoration(
                                color: HexColor(widget.event.color),
                                borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                          )
                        ],
                      ),
                    ),
                    widget.event.status==Status.Accepted?
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                child: new Text('TERMINA', style: button_card),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                                color: black,
                                elevation: 15,
                                onPressed:
                                      () => _actionEndAlert(),

                              ),
                            ],
                          ),
                        ):widget.event.status==Status.Ended?
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                color: HexColor(widget.event.color),
                                boxShadow: <BoxShadow> [BoxShadow(color: Colors.black45,
                                  offset: Offset(1.0, 2.5),
                                  blurRadius: 5.0,)]

                              ),
                              child: Text('INCARICO TERMINATO', style: button_card),
                              padding: EdgeInsets.all(10),

                            ),
                          )
                            ,
                        ],
                      ),
                    ):
                    Container(
                      height: 30,)
                      /*child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      Icon(
                        Icons.notifications,
                        size: 40,
                      ),
                      Text("Avvisami (15m)", style: subtitle_rev),
                      SizedBox(width: 30),
                      Switch(value: true, activeColor: c, onChanged: (v) {})
                    ],
                  ),*/

                  ])),
            ])));
  }

  void _actionEndAlert(){
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return dialogAlert(
            action: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: new Text('Annulla', style: label),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 15,),
                  RaisedButton(
                    child: new Text('CONFERMA', style: button_card),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(15.0))),
                    color: black,
                    elevation: 15,
                    onPressed: () => _actionEndConferma(context),
                  ),
                ]),
            content:  SingleChildScrollView(
                child: ListBody(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text("Confermi la terminazione dell'incarico?", style: label,),
                  ),
                ]),
              ),
            tittle: "TERMINA INCARICO",
            context: context,
          );
    });
  }
  void getColor() async {
    var a = await Utils.getColor(widget.event.category);
    if (color != a) {
      setState(() {
        color = a;
      });
    }
  }

  void _actionEndConferma(BuildContext context){
    widget.event.status = Status.Ended;
    EventsRepository().endEvent(widget.event);
    Account operator = BlocProvider.of<AuthenticationBloc>(context).account;
    Utils.notify(token:Account.fromMap(widget.event.idSupervisor, widget.event.supervisor).token, title: operator.surname+" "+operator.name+" ha terminato il lavoro "+widget.event.title);
    Navigator.of(context).pop();
    Navigator.of(context).pop();

  }

}
