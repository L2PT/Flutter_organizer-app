//import 'package:flutter/material.dart';
//import 'package:venturiautospurghi/models/event.dart';
//import 'package:venturiautospurghi/utils/theme.dart';
//import 'package:venturiautospurghi/utils/global_contants.dart' as global;
//
//class persistenNotification extends StatefulWidget {
//  @override
//  _persistenNotificationState createState() => _persistenNotificationState();
//
//
//  }
//class _persistenNotificationState extends State<persistenNotification> {
//
//  List<Event> listEvent;
//  bool checkMultiEvent;
//
//  @override
//  void initState() {
//    super.initState();
//    checkMultiEvent = false;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//
//    showBottomSheet(context: context, builder: (BuildContext context){
//      if(checkMultiEvent){
//        return viewPersistentMultiEvent();
//      }else{
//        return viewPersistentSingleEvent();
//      }
//    });
//
//
//  }
//
//  Widget viewPersistentMultiEvent(){
//    return Card(
//      child: Container(
//        height: 130,
//        child: Column(
//          children: <Widget>[
//            Row(
//              children: <Widget>[
//                Container(
//                  decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(4.0),
//                      color: Colors.grey),
//                  width: 6,
//                  height: 60,
//                  margin: const EdgeInsets.symmetric(horizontal: 15.0),
//                ),
//                Container(
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      Text(
//                        'INCARICHI IN SOSPESO',
//                        style: button_card,
//                      ),
//                      Text(
//                        'NUMERO DI INCARICHI IN SOSPESO',
//                        style: Text12WhiteNormal,
//                      ),
//                      Row(
//                        children: <Widget>[
//
//                        ],
//                      ),
//                    ],
//                  ),
//                  margin: const EdgeInsets.symmetric(vertical: 4.0),
//                )
//              ],
//            ),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: <Widget>[
//                Container(
//                  child: RaisedButton(
//                    child: new Text('RIFIUTA', style: button_card),
//                    shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
//                    color: Color(global.Constants().category[e.category]),
//                    elevation: 15,
//                    onPressed: () => _actionRifiuta(),
//                  ),
//                  margin: EdgeInsets.only(right: 10),
//                ),
//                Container(
//                  child: RaisedButton(
//                    child: new Text('CONFERMA', style: button_card),
//                    shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
//                    color: Color(global.Constants().category[e.category]),
//                    elevation: 15,
//                    onPressed: () => _actionConferma(),
//                  ),
//                  margin: EdgeInsets.only(right: 10),
//                )
//              ],
//            )
//          ],
//        ),
//      ),
//      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
//      elevation: 5,
//      color: dark,
//    );
//
//  }
//
//  Widget viewPersistentSingleEvent(){
//
//  }
//
//  List<Widget> rectangleEvent(){
//    List<Widget> r = new List<Widget>();
//
//  }
//  void _actionConferma(){
//
//  }
//
//  void _actionRifiuta(){
//
//  }
//}
