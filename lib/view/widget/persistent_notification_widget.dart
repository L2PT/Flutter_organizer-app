//import 'package:flutter/material.dart';
//import 'package:venturiautospurghi/utils/global_contants.dart' as global;
//import 'package:venturiautospurghi/utils/global_methods.dart';
//import 'package:venturiautospurghi/utils/theme.dart';
//import 'package:venturiautospurghi/models/event.dart';
//import 'package:venturiautospurghi/view/widget/card_event_widget.dart';
//a
//class PersistentNotification extends StatefulWidget {
//  List<Event> events;
//  PersistentNotification(this.events,{Key key}) : super(key: key);
//
//  @override
//  _PersistentNotificationState createState() => _PersistentNotificationState();
//}
//
//class _PersistentNotificationState extends State<PersistentNotification> {
//  bool flagMultiEvent;
//  Map<String, int> mapWaitingEvent = new Map<String, int>();
//
//  @override
//  Widget build(BuildContext context) {
//    mapWaitingEvent = new Map<String, int>();
//    widget.events.forEach((event) => _setMapWaitingEvent(event));
//    return Container(
//      child: widget.events.length > 1
//          ? viewPersistentMultiEvent()
//          : viewPersistentSingleEvent(),
//    );
//  }
//
//  Widget viewPersistentMultiEvent() {
//    return Card(
//      child: Container(
//          height: 150,
//          child: Padding(
//            padding: EdgeInsets.all(10),
//            child: Column(
//              children: <Widget>[
//                Row(
//                  children: <Widget>[
//                    Container(
//                      decoration: BoxDecoration(
//                          borderRadius: BorderRadius.circular(4.0),
//                          color: Colors.grey),
//                      width: 6,
//                      height: 70,
//                      margin: const EdgeInsets.symmetric(horizontal: 15.0),
//                    ),
//                    Container(
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Text(
//                            'INCARICHI IN SOSPESO',
//                            style: button_card,
//                          ),
//                          SizedBox(height: 5),
//                          Text(
//                            'NUMERO DI INCARICHI IN SOSPESO',
//                            style: white_default,
//                          ),
//                          Row(
//                            children: viewPersistentEventContent(),
//                          ),
//                        ],
//                      ),
//                    )
//                  ],
//                ),
//                Row(
//                    mainAxisAlignment: MainAxisAlignment.end,
//                    children: <Widget>[
//                      Container(
//                        margin: const EdgeInsets.only(
//                          right: 15,
//                        ),
//                        child: RaisedButton(
//                          child: new Text('VISUALIZZA', style: button_card),
//                          shape: RoundedRectangleBorder(
//                              borderRadius:
//                                  BorderRadius.all(Radius.circular(15.0))),
//                          color: Colors.grey,
//                          elevation: 5,
//                          onPressed: () => _actionVisualizza(),
//                        ),
//                      ),
//                    ])
//              ],
//            ),
//          )),
//      elevation: 5,
//      color: black,
//    );
//  }
//
//  Widget viewPersistentSingleEvent() {
//    return cardEvent(
//      buttonArea: true,
//      dateView: true,
//      hourSpan: 0,
//      e: widget.events[0],
//      hourHeight: 160,
//      actionEvent: (ev)=> Utils.PushViewDetailsEvent(context, widget.events[0]),
//    );
//  }
//
//  List<Widget> viewPersistentEventContent() {
//    List<Widget> r = new List<Widget>();
//    mapWaitingEvent.forEach((color, text) => r.add(Container(
//        width: 30,
//        height: 30,
//        margin: EdgeInsets.only(right: 15, top: 10),
//        decoration: BoxDecoration(
//            borderRadius: BorderRadius.all(Radius.circular(5.0)),
//            color: HexColor(color)),
//        child: Center(
//          child: Text("$text", style: button_card),
//        ))));
//    return r;
//  }
//
//  void _actionVisualizza() {
//    Utils.NavigateTo(context,global.Constants.waitingEventListRoute,null);
//  }
//
//  void _setMapWaitingEvent(Event event) {
//    if (mapWaitingEvent[event.color] == null) {
//      mapWaitingEvent[event.color] = 1;
//    } else {
//      mapWaitingEvent[event.color] = mapWaitingEvent[event.color] + 1;
//    }
//  }
//}
