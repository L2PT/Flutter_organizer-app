import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/waiting_event_list/waiting_event_list_cubit.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';
import 'package:venturiautospurghi/views/widgets/splash_screen.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';

class WaitingEventList extends StatelessWidget {
  Account account;
  DateTime dataCorrente;
  bool ready = false;

  @override
  Widget build(BuildContext context) {
    final CloudFirestoreService repository = RepositoryProvider.of<CloudFirestoreService>(context);
    final Account account = context.bloc<AuthenticationBloc>().account;

    return new BlocProvider(
        create: (_) => WaitingEventListCubit(repository, account),
        child: Material(
            elevation: 12.0,
            borderRadius: new BorderRadius.only(
                topLeft: new Radius.circular(16.0),
                topRight: new Radius.circular(16.0)),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded( child:  _eventList())
                ],
              ),
            ),
        )
    );
  }
}

class _eventList extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    List<List<Event>> eventsGroupedByDay;

    void _onCalendarPressed(){
      DateTime date = TimeUtils.truncateDate(DateTime.now(), "month");
      context.bloc<MobileBloc>().add(NavigateEvent(Constants.monthlyCalendarRoute, [null, date]));
    }

    Widget buildGroupEventList = ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: eventsGroupedByDay.length,
      itemBuilder: (context, index) => _listGroup(eventsGroupedByDay[index]),);

    Widget noContent =  Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(bottom: 5) ,child:Text("Nessun incarico in sospeso",style: title,)),
          Padding(padding: EdgeInsets.only(bottom: 5), child: Text("Controlla i tuoi incarichi accettati", style: subtitle,)),
          RaisedButton(
            child: new Text('VEDI CALENDARIO', style: button_card),
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(15.0))),
            color: black,
            elevation: 15,
            onPressed: _onCalendarPressed,
          ),
        ],
      ),

    );


    return BlocBuilder<WaitingEventListCubit, WaitingEventListState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if(state is ReadyEvents) {
          if(state.events.length > 0) {
            eventsGroupedByDay = state.events.groupBy((event) => TimeUtils.truncateDate(event.start, "day"));
            return buildGroupEventList;
          } else return noContent;
        } else return LoadingScreen();
      },
    );
  }
}

class _listGroup extends StatelessWidget {
  _listGroup(this.eventsGroup) {
    groupDate = TimeUtils.truncateDate(eventsGroup[0].start, "day");
  }

  final List<Event> eventsGroup;
  final formatter = new DateFormat('MMMM yyyy', 'it_IT');
  DateTime groupDate;

  @override
  Widget build(BuildContext context) {

    void _onDayPressed() {
      context.bloc<MobileBloc>().add(NavigateEvent(Constants.dailyCalendarRoute, [null, groupDate]));
    }

    List<Widget> dateHeader = [
      Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(groupDate.day.toString(), style: title2),
          ),
          Expanded(
            flex: 10,
            child: Text(formatter.format(groupDate).toUpperCase(), style: subtitle2),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                icon: new Icon(Icons.today),
                alignment: Alignment.centerRight,
                color: Colors.grey,
                onPressed: _onDayPressed),
          ),
        ],
      ),
      Expanded(
          flex: 9,
          child: Center(
              child: new Container(
                  margin: const EdgeInsets.only( left: 10.0, right: 10.0, top: 0.0, bottom: 15.0),
                  child: Divider(color: Colors.grey, height: 0)
              ))
      )];

      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ...dateHeader,
            ...eventsGroup.map((event) => _listTileEvent(event)).toList()
          ]
      );
    }
}

class _listTileEvent extends StatelessWidget {
  _listTileEvent(this.event);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        flex: 9,
        child: cardEvent(
          event: event,
          dateView: false,
          hourHeight: 140,
          hourGridSpan: 0,
          buttonArea: <String,Function(Event)>{"Rifiuta":context.bloc<WaitingEventListCubit>().cardActionReject,"Conferma":context.bloc<WaitingEventListCubit>().cardActionConfirm},
          onTapAction: (event)=> PlatformUtils.navigator(context, event),
        ),
      ),
      SizedBox(height: 15)
    ]);
  }
}
