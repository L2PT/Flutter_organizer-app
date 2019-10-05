import 'package:fb_auth/data/classes/auth_user.dart';
import 'package:fb_auth/data/services/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/view/widget/card_event_widget.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;

final _auth = FBAuth();

class waitingEvent extends StatefulWidget {
  waitingEvent({Key key}) : super(key: key);

  @override
  _waitingEventState createState() => _waitingEventState();
}

class _waitingEventState extends State<waitingEvent> {
  AuthUser user;
  DateTime dataCorrente;

  @override
  void initState()  {
    super.initState();
    getUser();
  }

  void getUser() async{
    this.user = await _auth.currentUser();
  }
  @override
  Widget build(BuildContext context) {
    return new Material(
      elevation: 12.0,
      borderRadius: new BorderRadius.only(
          topLeft: new Radius.circular(16.0),
          topRight: new Radius.circular(16.0)),
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[Expanded(
              child: StreamBuilder(
                  stream: _readWaitngEventData(user.uid),
                  builder: (BuildContext c,
                      AsyncSnapshot<List<Event>> listEvent) {
                    if(!listEvent.hasData){
                      return const Text("Loging");
                    }
                    return ListView.builder(
                      physics: new BouncingScrollPhysics(),
                      itemBuilder: (context, index) =>
                          _buildWaitingEvent(listEvent.data[index]),
                    );
                  }
              )
          )
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingEvent(Event evento) {
    List<Widget> r = new List<Widget>();
    if (dataCorrente != evento.start) {
      dataCorrente = evento.start;
      r.add(_viewDateHeader(dataCorrente));
    }
    r.add(_viewEvent(evento));
    return Row(
      children: r,
    );
  }



void _onDaySelected(DateTime day) {
  Navigator.of(context).pushReplacementNamed(
      global.Constants.dailyCalendarRoute,
      arguments: day);
}

Widget _viewEvent(Event e) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            flex: 9,
            child: cardEvent(
              e: e,
              hourHeight: 140,
              buttonArea: true,
            ),
          ),
        ]),
        SizedBox(height: 15)
      ]);
}

Widget _viewDateHeader(DateTime dateEvent) {
  int day = dateEvent.day;
  var formatter = new DateFormat('MMMM yyyy', 'it_IT');
  String meseAnno = formatter.format(dateEvent);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              '$day',
              style: dayWaitingEvent,
            ),
          ),
          Expanded(
            flex: 10,
            child: Text(
              meseAnno.toUpperCase(),
              style: datWaitingEvent,
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                icon: new Icon(Icons.today),
                alignment: Alignment.centerRight,
                color: Colors.grey,
                onPressed: () => _onDaySelected(dateEvent)),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(
            flex: 9,
            child: Center(
              child: new Container(
                  margin: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 0.0, bottom: 15.0),
                  child: Divider(
                    color: Colors.grey,
                    height: 0,
                  )),
            ),
          ),
        ],
      ),
    ],
  );
}


Stream<List<Event>> _readWaitngEventData(String uid) {
    var elem = PlatformUtils.fire
        .collection(global.Constants.tabellaEventi)
        /*.where(global.Constants.tabellaEventi_stato,
        isLessThan: Status.Accepted)
        .where(global.Constants.tabellaEventi_subOpe, isEqualTo: uid)
        .orderBy(global.Constants.tabellaEventi_dataInizio) */;

  return elem.snapshots().map((list) =>
      list.documents.map((list) =>
          Event.fromSnapshot(list)).toList());
}

}
