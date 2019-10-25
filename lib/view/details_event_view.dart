import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/backdrop_bloc/backdrop_bloc.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/view/widget/fab_widget.dart';

class DetailsEvent extends StatefulWidget {
  final route = global.Constants.detailsEventViewRoute;
  final Event event;

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
  String dateToText = "";
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
    tabsContents = _buildTabsContents();
    _tabController = new TabController(vsync: this, length: tabsHeaders.length);
    getColor();
    if(widget.event.idOperator == account.id && widget.event.status < Status.Seen){
      EventsRepository.changeState(widget.event, "Stato", Status.Seen);
      widget.event.status = Status.Seen;
    }
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
                color: almost_dark,
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
                    //Text(widget.event.address, style: subtitle_rev)
                  ],
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
                indent: 35,
                color: almost_dark,
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
                    Text(widget.event.supervisor.surname, style: subtitle_rev),
                    Text(widget.event.supervisor.name, style: subtitle_rev),
                  ],
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
                indent: 35,
                color: almost_dark,
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
                    Text("0-10", style: subtitle_rev)
                  ],
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
                indent: 35,
                color: almost_dark,
              ),
              account.supervisor ? _viewStateWidget(3) : Container(),
              Container(
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
                            Text(
                              "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam",
                              style: subtitle_rev,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),
                            SizedBox(height: 15),
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
                            )
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
        child: ListView(physics: BouncingScrollPhysics(), children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            child: Row(children: <Widget>[
              Icon(
                Icons.insert_drive_file,
                size: sizeIcon,
                color: dark,
              ),
              SizedBox(
                width: padding,
              ),
              Container(
                child: Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "file Mappa tizio caio semproniofdfdsfdsfdsfdsfd.pdf",
                          style: subtitle.copyWith(
                              color: dark, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.visible,
                        )
                      ],
                    )),
              )
            ]),
          )
        ]));

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
                        child: new Text(
                            "riautospurgh(26111): Accessing hidden method Ljava/security/spec/ECParameterSpec;->setCurveName(Ljava/lang/String;)V (greylist, reflection, allowed)"
                                "W/turiautospurgh(26111):",
                            style: subtitle_rev),
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
        floatingActionButton: widget.event.end.isBefore(DateTime.now().add(Duration(hours: 2)))&&account.supervisor?Container(
            decoration: BoxDecoration(
                color: grey, borderRadius: BorderRadius.circular(100)),
            child: Padding(
                padding: EdgeInsets.all(2),
                child: FloatingActionButton(
                  child: Icon(Icons.delete),
                  onPressed: (){
                    Navigator.pop(context, global.Constants.DELETE_SIGNAL);
                  },
                  backgroundColor: dark,
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
                          child: Container(color: dark),
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
                                  color: dark,
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
                                    style: subtitle.copyWith(color: dark)),
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
                                  color: dark,
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
                                      unselectedLabelColor: dark,
                                      labelStyle: title.copyWith(fontSize: 16),
                                      labelColor: dark,
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
                    Container(
                      height: 30,
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
                    )
                  ])),
            ])));
  }

  Widget _viewStateWidget(int status) {
    switch (status) {
      case Status.New:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.work,
                size: sizeIcon,
              ),
              SizedBox(
                width: padding,
              ),
              Text("Nuovo", style: subtitle_rev)
            ],
          ),
        );
      case Status.Delivered:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.work,
                size: sizeIcon,
              ),
              SizedBox(
                width: padding,
              ),
              Text("Consegnato", style: subtitle_rev)
            ],
          ),
        );
      case Status.Seen:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.work,
                size: sizeIcon,
              ),
              SizedBox(
                width: padding,
              ),
              Text("Visualizzato", style: subtitle_rev)
            ],
          ),
        );
      case Status.Accepted:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.work,
                size: sizeIcon,
              ),
              SizedBox(
                width: padding,
              ),
              Text("Accettato", style: subtitle_rev)
            ],
          ),
        );
      case Status.Rejected:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.work,
                size: sizeIcon,
              ),
              SizedBox(
                width: padding,
              ),
              Text("Rifiutato", style: subtitle_rev)
            ],
          ),
        );
      case Status.Ended:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.work,
                size: sizeIcon,
              ),
              SizedBox(
                width: padding,
              ),
              Text("Terminato", style: subtitle_rev)
            ],
          ),
        );
    }
  }

  void getDate(DateTime d) async {
    var formatter = new DateFormat(' MMM\n  d\n E', "it_IT");
    String formatted = formatter.format(d);
    setState(() {
      dateToText = formatted;
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

}
