import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import '../utils/theme.dart';
import '../models/event_model.dart';

class DetailsEvent extends StatefulWidget {
  final Event event;

  DetailsEvent({Key key,
    @required this.event
  })  : assert(event != null),
        super(key: key);

  @override
  _DetailsEventState createState()=>_DetailsEventState();
}

class _DetailsEventState extends State<DetailsEvent> with TickerProviderStateMixin {
  String dateToText = "";
  Color c = Colors.blueAccent;
  final List<Tab> tabs = <Tab>[
    new Tab(text: "DETTAGLIO"),
    new Tab(text: "DOCUMENTI"),
    new Tab(text: "NOTE")
  ];

  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: tabs.length);
    getDate(widget.event.start);
    c = Color(global.Constants().category[widget.event.category]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //MAIN BUILEDER METHODS
  @override
  Widget build(BuildContext context) {
    return new Material(
        elevation: 12.0,
        child: Stack(
            children: <Widget>[
              Container(
                  child: Column(
                      children: <Widget>[Expanded(
                        flex: 6,
                        child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: Container(color: dark),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(color: c),
                              )
                            ]
                        ),
                      ),Expanded(
                        flex: 4,
                        child: Container(color: grey),
                      )
                    ]
                  )
              ),
              Container(
                  child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.0))
                          ),
                          height: 100,
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 50,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: dark,
                                    borderRadius: BorderRadius.all(Radius.circular(25.0))
                                ),
                                width: 45,
                                height: 80,
                                padding: EdgeInsets.only(right: 5),
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: Text(dateToText, style: title_rev.copyWith(fontSize: 18)),
                                )
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 20),
                                  Text(widget.event.title.toUpperCase(), style: title),
                                  Text(widget.event.category.toUpperCase(), style: subtitle.copyWith(color: dark)),
                                ],
                              )
                            ],
                          ),
                      ),Expanded(
                          child:Row(
                            children: <Widget>[
                              Expanded(
                                child:Container(
                                  decoration: BoxDecoration(
                                      color: dark,
                                      borderRadius: BorderRadius.all(Radius.circular(40.0))
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(height: 20,),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: whitebackground,
                                          borderRadius: BorderRadius.all(Radius.circular(30.0))
                                      ),
                                        child: new TabBar(
                                          isScrollable: true,
                                          unselectedLabelColor: Colors.grey,
                                          labelColor: Colors.white,
                                          indicatorSize: TabBarIndicatorSize.tab,
                                          indicator: new BubbleTabIndicator(
                                            indicatorHeight: 40.0,
                                            indicatorColor: c,
                                            tabBarIndicatorSize: TabBarIndicatorSize.tab,
                                          ),
                                          tabs: tabs,
                                          controller: _tabController,
                                        ),
                                      ),Expanded(
                                        child: new TabBarView(
                                          controller: _tabController,
                                          children: tabs.map((Tab tab) {
                                            return new Center(
                                                child: new Text(
                                                  tab.text,
                                                  style: title_rev
                                                )
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 10,
                                height: 150,
                                decoration: BoxDecoration(
                                    color: c,
                                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 65,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 30,),
                              Icon(Icons.notifications, size: 40,),
                              Text("Avvisami (15m)", style: subtitle_rev),
                              SizedBox(width: 30),
                              Switch(value: true, activeColor: c, onChanged: (v){})
                            ],
                          ),
                        )
                      ]
                  )
              ),
            ]
        )
    );
  }

  void getDate(DateTime d) async{
    initializeDateFormatting("it_IT", null).then((_){
      var formatter = new DateFormat(' MMM\n  d\n E');
      String formatted = formatter.format(d);
      setState(() {
        dateToText = formatted;
      });
    });
  }






















//--

        //--


      //METODI DI CALLBACK


      //METODI DI UTILITY


}