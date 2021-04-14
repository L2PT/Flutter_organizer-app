import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/cubit/event_filter_view/event_filter_view_cubit.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';
import 'package:venturiautospurghi/views/widgets/filter_event_widget.dart';
import 'package:venturiautospurghi/views/widgets/responsive_widget.dart';

class EventFilterView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    CloudFirestoreService repository = RepositoryProvider.of<
        CloudFirestoreService>(context);

    return new BlocProvider(
        create: (_) => EventFilterViewCubit(repository),
        child: ResponsiveWidget(
          smallScreen: _smallScreen(),
          largeScreen: _largeScreen(),
        ));
  }

}

class _largeScreen extends StatelessWidget {

  _largeScreen();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder <EventFilterViewCubit, EventFilterViewState>(
        builder: (context, state) {
          return !(state is ReadyEventFilterView) ? Center(child: CircularProgressIndicator()) : Container(
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
                        FilterWidgetEvent(
                          hintTextSearch: 'Cerca gli interventi',
                          clearFilter: context.read<EventFilterViewCubit>().clearFilter,
                          filterEvent:  context.read<EventFilterViewCubit>().filterEvent,
                          maxHeightContainerExpanded: MediaQuery.of(context).size.height-270,
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
                        Text("Tutti Gli Incarichi ", style: title, textAlign: TextAlign.left,),
                        SizedBox(height: 10,),
                        (context.read<EventFilterViewCubit>().state as ReadyEventFilterView).filteredEvent().length>0 ?
                        Container(
                            height: MediaQuery.of(context).size.height - 110,
                            child: GridView(
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 350.0,
                                  mainAxisSpacing: 5.0,
                                  crossAxisSpacing: 5.0,
                                  childAspectRatio: 2.3,
                                ),
                                children: (context.read<EventFilterViewCubit>().state as ReadyEventFilterView).filteredEvent().map((event)=> Container(
                                    child: cardEvent(
                                      event: event,
                                      dateView: true,
                                      hourHeight: 120,
                                      gridHourSpan: 0,
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

}

class _smallScreen extends StatelessWidget {

  _smallScreen();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12.0,
      borderRadius: new BorderRadius.only(
          topLeft: new Radius.circular(16.0),
          topRight: new Radius.circular(16.0)),
      child: Column(
        children: [
          FilterWidgetEvent(
            hintTextSearch: 'Cerca gli interventi',
            clearFilter: context.read<EventFilterViewCubit>().clearFilter,
            filterEvent: context.read<EventFilterViewCubit>().filterEvent,
          ),
          BlocBuilder<EventFilterViewCubit, EventFilterViewState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                return !(state is ReadyEventFilterView) ? Center(
                    child: CircularProgressIndicator()) : state.listEventFiltered.length > 0 ?
                Expanded(child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10,),
                        physics: BouncingScrollPhysics(),
                        padding: new EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: state.listEventFiltered.length,
                        itemBuilder: (context, index) {
                          return Container(
                              child: cardEvent(
                                event: state.listEventFiltered[index],
                                dateView: true,
                                hourHeight: 120,
                                gridHourSpan: 0,
                                buttonArea: null,
                                onTapAction: (event) => PlatformUtils.navigator(context, Constants.detailsEventViewRoute, event),
                              )
                          );
                        }))) : Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            "Nessun incarico da mostrare", style: title,)),
                    ],
                  ),
                );
              })
        ],
      ),);
  }


}
