import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/events_bloc/events_bloc.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/view/widget/card_event_widget.dart';

class waitingEvent extends StatefulWidget {
  waitingEvent({Key key}) : super(key: key);

  @override
  _waitingEventState createState() => _waitingEventState();
}

class _waitingEventState extends State<waitingEvent> {
  Account account;
  DateTime dataCorrente;
  bool ready = false;

  @override
  void initState()  {
    super.initState();
    account = BlocProvider.of<AuthenticationBloc>(context).account;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          if (state is Loaded) {
            //get data
            BlocProvider.of<EventsBloc>(context).dispatch(FilterEventsByWaiting());
            ready = true;
          }else if(state is Filtered && ready){
            return Material(
              elevation: 12.0,
              borderRadius: new BorderRadius.only(
                  topLeft: new Radius.circular(16.0),
                  topRight: new Radius.circular(16.0)),
              child: Padding(
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
                              _buildWaitingEvent(state.events[index]),):Container()
                    )
                  ],
                ),
              ),
            );
          }
          return Container();
        }
    );
  }

  Widget _buildWaitingEvent(Event evento) {
    List<Widget> r = new List<Widget>();
    if (dataCorrente != evento.start) {
      dataCorrente = evento.start;
      _viewDateHeader(dataCorrente).forEach((row) => r.add(row));
    }
    r.add(_viewEvent(evento));
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: r
    );
  }

  void _onDaySelected(DateTime date) {
    date = Utils.formatDate(date, "day");
    Utils.NavigateTo(context, global.Constants.dailyCalendarRoute, [null, date]);
  }

  Widget _viewEvent(Event e) {
    return Row(children: <Widget>[
      Expanded(
        flex: 9,
        child: cardEvent(
          e: e,
          dateView: false,
          hourHeight: 140,
          buttonArea: true,
          actionEvent: (ev)=> Utils.PushViewDetailsEvent(context, ev),
        ),
      ),
      SizedBox(height: 15)
    ]);
  }

  List<Widget> _viewDateHeader(DateTime dateEvent) {
    int day = dateEvent.day;
    var formatter = new DateFormat('MMMM yyyy', 'it_IT');
    String meseAnno = formatter.format(dateEvent);
    List<Widget> r = new List<Widget>();
    r.add(
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
    );
    r.add(
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
    );
    return r;
  }

}
