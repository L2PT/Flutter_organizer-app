import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/cubit/event_filter_view/filter_event_list_cubit.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/card_event_widget.dart';
import 'package:venturiautospurghi/views/widgets/filter/filter_events_widget.dart';
import 'package:venturiautospurghi/views/widgets/responsive_widget.dart';

class FilterEventList extends StatelessWidget {

  Map<String, dynamic> filters;

  FilterEventList({Map<String, dynamic>? filters}) : this.filters = filters??{};

  @override
  Widget build(BuildContext context) {
    CloudFirestoreService repository = context.read<CloudFirestoreService>();

    return new BlocProvider(
        create: (_) => FilterEventListCubit(repository, filters),
        child: ResponsiveWidget(
          smallScreen: _smallScreen(),
          largeScreen: _largeScreen(),
        ));
  }
}

class _largeScreen extends StatefulWidget {

  _largeScreen();

  @override
  State<StatefulWidget> createState() => _largeScreenState();

}

class _largeScreenState extends State<_largeScreen>  {

  @override
  void initState() {
    context.read<FilterEventListCubit>().scrollController.addListener(() {
      if (context.read<FilterEventListCubit>().scrollController.position.pixels == context.read<FilterEventListCubit>().scrollController.position.maxScrollExtent) {
        if(context.read<FilterEventListCubit>().canLoadMore)
          context.read<FilterEventListCubit>().loadMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder <FilterEventListCubit, FilterEventListState>(
        builder: (context, state) {
          return !(state is ReadyFilterEventList) ? Center(child: CircularProgressIndicator()) : Container(
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
                        EventsFilterWidget(
                          hintTextSearch: 'Cerca gli interventi',
                          onSearchFieldChanged: context.read<FilterEventListCubit>().onFiltersChanged,
                          onFiltersChanged: context.read<FilterEventListCubit>().onFiltersChanged,
                          maxHeightContainerExpanded: MediaQuery.of(context).size.height-270,
                          textSearchFieldVisible: true,
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
                        context.read<FilterEventListCubit>().state.listEventFiltered.length>0 ? //TODO add pagination here
                        Container(
                            height: MediaQuery.of(context).size.height - 110,
                            child: GridView(
                              controller: context.read<FilterEventListCubit>().scrollController,
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 350.0,
                                  mainAxisSpacing: 5.0,
                                  crossAxisSpacing: 5.0,
                                  childAspectRatio: 3,
                                ),
                                children: context.read<FilterEventListCubit>().state.listEventFiltered.map((event)=> Container(
                                    child: CardEvent(
                                      event: event,
                                      height: 120,
                                      showEventDetails: true,
                                      onTapAction: (event) => PlatformUtils.navigator(context,Constants.detailsEventViewRoute,  <String,dynamic>{"objectParameter" : event}),
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

  @override
  void dispose() {
    context.read<FilterEventListCubit>().scrollController.dispose();
    super.dispose();
  }

}

class _smallScreen extends StatefulWidget {

  _smallScreen();

  @override
  State<StatefulWidget> createState() => _smallScreenState();

}

class _smallScreenState extends State<_smallScreen> with TickerProviderStateMixin {

  @override
  void initState() {
    context.read<FilterEventListCubit>().scrollController.addListener(() {
      if (context.read<FilterEventListCubit>().scrollController.position.pixels == context.read<FilterEventListCubit>().scrollController.position.maxScrollExtent) {
        if(context.read<FilterEventListCubit>().canLoadMore)
          context.read<FilterEventListCubit>().loadMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12.0,
      borderRadius: new BorderRadius.only(
          topLeft: new Radius.circular(16.0),
          topRight: new Radius.circular(16.0)),
      child: Column(
        children: [
          SizedBox(height: 15,),
          EventsFilterWidget(
            hintTextSearch: 'Cerca gli interventi',
            onSearchFieldChanged: context.read<FilterEventListCubit>().onFiltersChanged,
            onFiltersChanged: context.read<FilterEventListCubit>().onFiltersChanged,
          ),
          BlocBuilder<FilterEventListCubit, FilterEventListState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                return !(state is ReadyFilterEventList) ? Center(
                    child: CircularProgressIndicator()) : state.listEventFiltered.length > 0 ?
                Expanded(child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: ListView.separated(
                        controller: context.read<FilterEventListCubit>().scrollController,
                        separatorBuilder: (context, index) => SizedBox(height: 10,),
                        physics: BouncingScrollPhysics(),
                        padding: new EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: state.listEventFiltered.length+1,
                        itemBuilder: (context, index) => index != state.listEventFiltered.length?
                        Container(
                          child: CardEvent(
                            event: state.listEventFiltered[index],
                            height: 120,
                            showEventDetails: true,
                            onTapAction: (event) => PlatformUtils.navigator(context, Constants.detailsEventViewRoute, event)
                          )
                        ) : context.read<FilterEventListCubit>().canLoadMore?
                        Center(
                          child: Container(
                            margin: new EdgeInsets.symmetric(vertical: 13.0),
                            height: 26,
                            width: 26,
                            child: CircularProgressIndicator(),
                        )):Container()
                    ))) : Container(
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

  @override
  void dispose() {
    context.read<FilterEventListCubit>().scrollController.dispose();
    super.dispose();
  }

}
