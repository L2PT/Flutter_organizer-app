import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/cubit/filter_events/filter_events_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/filter_wrapper.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/colors.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/filter_widget.dart';
import 'package:venturiautospurghi/views/widgets/list_tile_operator.dart';
import 'package:venturiautospurghi/views/widgets/platform_datepicker.dart';

class EventsFilterWidget extends FilterWidget {

  final Function callbackFiltersChanged;
  final Function callbackSearchFieldChanged;
  late bool isSupervisor;
  final double maxHeightContainerExpanded;

  EventsFilterWidget({
    String hintTextSearch = '',
    required void Function(Map<String, FilterWrapper> filters) onFiltersChanged,
    required void Function(Map<String, FilterWrapper> filters) onSearchFieldChanged,
    bool isExpandable = true,
    bool filtersBoxVisibile = false,
    this.maxHeightContainerExpanded = 400,
    bool textSearchFieldVisible = false,
  }) : callbackFiltersChanged = onFiltersChanged,
      callbackSearchFieldChanged = onSearchFieldChanged, super(
        filtersBoxVisibile: filtersBoxVisibile,
        isExpandable: isExpandable,
        hintTextSearchField: hintTextSearch,
        textSearchFieldVisible: textSearchFieldVisible
  );

  List<Widget> buildCategoriesList(BuildContext context) {
    int i = 0;

    return context.read<EventsFilterCubit>().categories.map((categoryName, categoryColor) =>
      MapEntry(  Column(children: <Widget>[
        Theme(data: ThemeData(
          unselectedWidgetColor: grey, // Your color
        ), child:
        context.read<EventsFilterCubit>().getCategorySelected(categoryName)? new Transform.scale(
          scale: largeScreen?1:1.5, child: Checkbox(
              value: context.read<EventsFilterCubit>().getCategorySelected(categoryName),
              splashRadius: 1,
              checkColor: white,
              hoverColor: HexColor(categoryColor),
              activeColor: HexColor(categoryColor),
              onChanged: (bool? val) => {
                context.read<EventsFilterCubit>().selectCategory(categoryName,val)},
            )): Checkbox(
          value: context.read<EventsFilterCubit>().getCategorySelected(categoryName),
          splashRadius: 1,
          checkColor: white,
          hoverColor: HexColor(categoryColor),
          activeColor: HexColor(categoryColor),
          onChanged: (bool? val) => {
            context.read<EventsFilterCubit>().selectCategory(categoryName,val)
          },
        )
        ),
            new Text(categoryName.toUpperCase(),
                style: context.read<EventsFilterCubit>().getCategorySelected(categoryName)? subtitle_rev.copyWith(fontSize: largeScreen?12:14,color: white) : subtitle.copyWith(fontSize: largeScreen?12:14, color: grey)),
          ]), i++)).keys.toList();
  }


  @override
  Widget filterBox(BuildContext context) {
    const double spaceIconText = 10;
    const double spaceInput = 10;
    DateFormat formatDate = DateFormat('d MMM y','it_IT');

    return new Form(
          key: context.read<EventsFilterCubit>().formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.tune),
                SizedBox(width: spaceIconText,),
                Text("FILTRI", style: subtitle_rev),
              ],
            ),
            SizedBox(height: 5.0,),
            Container(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textSearchFieldVisible?
                      Padding(
                          padding: EdgeInsets.only(top: spaceInput),
                          child: Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.clipboard, color: grey,),
                              SizedBox(width: spaceIconText),
                              Expanded(
                                  child: TextFormField(
                                    cursorColor: white,
                                    controller: context.read<EventsFilterCubit>().titleController,
                                    style: TextStyle(color: white),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                                      hintText: 'Cerca per titolo',
                                      hintStyle: subtitle,
                                      border: InputBorder.none,
                                    ),
                                    onSaved: (value) => context.read<EventsFilterCubit>().state.filters["title"]!.fieldValue = value??"",
                                  )),
                            ],
                      )): Container(),
                      Padding(
                        padding: EdgeInsets.only(top: spaceInput),
                        child: Row(
                            children: <Widget>[
                              Icon(Icons.map, color: grey,),
                              SizedBox(width: spaceIconText),
                              Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    cursorColor: white,
                                    controller: context.read<EventsFilterCubit>().addressController,
                                    style: TextStyle(color: white),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                                      hintText: 'Cerca per indirizzo',
                                      hintStyle: subtitle,
                                      border: InputBorder.none,
                                    ),
                                    onSaved: (value) => context.read<EventsFilterCubit>().state.filters["address"]!.fieldValue = value??"",
                                  )),
                            ]),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: spaceInput),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.contact_phone, color: grey,),
                              SizedBox(width: spaceIconText),
                              Expanded(
                                  child: TextFormField(
                                    controller: context.read<EventsFilterCubit>().customerController,
                                    cursorColor: white,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(color: white),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                                      hintText: 'Cerca per numero cliente',
                                      hintStyle: subtitle,
                                      border: InputBorder.none,),
                                    onSaved: (value) => context.read<EventsFilterCubit>().state.filters["phone"]!.fieldValue = value??"",
                                  )),
                            ],
                          )),
                      BlocBuilder<EventsFilterCubit, EventsFilterState>(
                          buildWhen: (previous, current) => previous.filters["startDate"] != current.filters["startDate"] || previous.filters["endDate"] != current.filters["endDate"],
                          builder: (context, state) {
                            return Padding(
                                padding: EdgeInsets.only(top: spaceInput),
                                child: Row(
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.calendarAlt, color: grey,),
                                    SizedBox(width: spaceIconText),
                                    Expanded(
                                      child: GestureDetector(
                                        child: Text(context.read<EventsFilterCubit>().state.filters["startDate"]!.fieldValue != null ?
                                        formatDate.format(context.read<EventsFilterCubit>().state.filters["startDate"]!.fieldValue):'Data inizio',
                                          style: subtitle.copyWith(color: context.read<EventsFilterCubit>().state.filters["startDate"]!.fieldValue != null ? white:grey, fontSize: largeScreen? 14:16 ),
                                          textAlign: TextAlign.center,),
                                        onTap: () =>
                                            PlatformDatePicker.selectDate(context,
                                              maxTime: DateTime(3000),
                                              currentTime: context.read<EventsFilterCubit>().state.filters["startDate"]!.fieldValue??DateTime.now(),
                                              onConfirm: (date) => context.read<EventsFilterCubit>().setStartDate(date),
                                            ),
                                      ),),
                                    IconButton(
                                        icon: Icon(Icons.clear, size: 16, color: grey),
                                        onPressed: () {
                                          context.read<EventsFilterCubit>().clearStartDate();
                                        }
                                    ),
                                    SizedBox(width: 10),
                                    Text('-', style: subtitle.copyWith(color: grey), textAlign: TextAlign.center,),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        child: Text(context.read<EventsFilterCubit>().state.filters["endDate"]!.fieldValue != null ?
                                        formatDate.format(context.read<EventsFilterCubit>().state.filters["endDate"]!.fieldValue):'Data fine',
                                          style: subtitle.copyWith(color: context.read<EventsFilterCubit>().state.filters["endDate"]!.fieldValue != null ? white:grey, fontSize: largeScreen? 14:16 ),
                                          textAlign: TextAlign.center,),
                                        onTap: () =>
                                            PlatformDatePicker.selectDate(context,
                                              minTime: TimeUtils.truncateDate(context.read<EventsFilterCubit>().state.filters["startDate"]!.fieldValue??DateTime.now(), "day"),
                                              maxTime: DateTime(3000),
                                              currentTime: context.read<EventsFilterCubit>().state.filters["startDate"]!.fieldValue??DateTime.now(),
                                              onConfirm: (date) => context.read<EventsFilterCubit>().setEndDate(date),
                                            ),
                                      ),),
                                    IconButton(
                                        icon: Icon(Icons.clear, size: 16,color: grey),
                                        onPressed: () {
                                          context.read<EventsFilterCubit>().clearEndDate();
                                        }
                                    ),

                                  ],
                                ));}),
                      if(isSupervisor) Row(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.hardHat, color: grey,),
                          SizedBox(width: 5),
                          Expanded(
                              child: Text("Operatori", style: subtitle.copyWith(color: grey))),
                          IconButton(
                              icon: Icon(Icons.add, color: grey),
                              onPressed: () {
                                context.read<EventsFilterCubit>().addOperatorDialog(context);
                              }
                          )
                        ],
                      ),
                      BlocBuilder<EventsFilterCubit, EventsFilterState>(
                          buildWhen: (previous, current) => previous.filters["suboperators"].toString() != current.filters["suboperators"].toString(),
                          builder: (context, state) {
                            return Column(children: <Widget>[...context.read<EventsFilterCubit>().state.filters["suboperators"]!.fieldValue.map((operator) => new ListTileOperator(
                                operator,
                                onRemove: context.read<EventsFilterCubit>().removeOperatorFromFilter,
                                darkStyle: true,
                                padding: PlatformUtils.isMobile?10:5,
                            ))]);
                      }),
                      Text('Categoria', style: subtitle.copyWith(color: white),),
                      Container(
                          height: largeScreen?120:100,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Center(
                              child: BlocBuilder<EventsFilterCubit, EventsFilterState>(
                                  buildWhen: (previous, current) => previous != current,
                                  builder: (context, state) {
                                    return GridView(
                                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: largeScreen?110:150.0,
                                        mainAxisSpacing: largeScreen?1.0:10.0,
                                        crossAxisSpacing: largeScreen?1.0:10.0,
                                        childAspectRatio: largeScreen?1.0:3/2,
                                        mainAxisExtent: largeScreen?50:80,
                                      ),
                                      scrollDirection: Axis.vertical,
                                      children: buildCategoriesList(context),
                                    );
                                  }),
                            )
                      ),),
                    ],
                  )),
              constraints: BoxConstraints(
                maxHeight: this.maxHeightContainerExpanded,
              ),
            ),

            ]));
  }

  @override
  void onSearchFieldTextChanged(BuildContext context, text){
    context.read<EventsFilterCubit>().onSearchFieldTextChanged(text);
  }

  @override
  void clearFilters(BuildContext context) {
    context.read<EventsFilterCubit>().clearFilters();
  }

  @override
  void applyFilters(BuildContext context){
    context.read<EventsFilterCubit>().notifyFiltersChanged(true);
  }

  @override
  TextEditingController titleController(BuildContext context) => context.read<EventsFilterCubit>().titleController;


  @override
  Widget build(BuildContext context) {
    CloudFirestoreService repository = context.read<CloudFirestoreService>();
    Account account = context.read<AuthenticationBloc>().account!;
    this.isSupervisor = account.supervisor;

    return new BlocProvider(
      create: (_) => EventsFilterCubit(repository, callbackSearchFieldChanged, callbackFiltersChanged),
      child: BlocBuilder<EventsFilterCubit, EventsFilterState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            super.showFiltersBox = context.read<EventsFilterCubit>().showFiltersBox;
            super.filtersBoxVisibile = state.filtersBoxVisibile;
            if(!state.isLoading()){
                return !textSearchFieldVisible?
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: super.build(context),
                ): super.build(context);
            } else return CircularProgressIndicator();
          }
      ),);
  }

}