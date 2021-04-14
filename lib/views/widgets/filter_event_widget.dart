import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/cubit/filter_event/filter_event_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/colors.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/filter_widget.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';
import 'package:venturiautospurghi/views/widgets/operator_list_widget.dart';
import 'package:venturiautospurghi/views/widgets/platform_datepicker.dart';

class FilterWidgetEvent extends FilterWidget {

  late bool isSupervisor;
  final void Function() clearFilter;
  final void Function(Event e,
      Map<String,bool> categorySelected,
      bool filterStartDate, bool filterEndDate) filterEvent;
  double maxHeightContainerExpanded;

  FilterWidgetEvent({
    bool filtersBoxVisibile = false,
    bool showIconExpanded = true,
    bool isWebMode = false,
    String hintTextSearch = '',
    this.isSupervisor = true,
    required this.clearFilter,
    required this.filterEvent,
    this.maxHeightContainerExpanded = 400,
  }) : super(
    filtersBoxVisibile: filtersBoxVisibile,
    showIconExpanded: showIconExpanded,
    hintTextSearch: hintTextSearch,
    isWebMode: isWebMode,
  );

  List<Widget> buildCategoriesList(BuildContext context) {
    int i = 0;


    return context.read<FilterEventCubbit>().categories.map((categoryName, categoryColor) =>
      MapEntry(  Column(children: <Widget>[
        Theme(data: ThemeData(
          unselectedWidgetColor: grey, // Your color
        ), child:
        context.read<FilterEventCubbit>().getCategorySelected(categoryName)? new Transform.scale(
          scale: isWebMode?1:1.5, child: Checkbox(
              value: context.read<FilterEventCubbit>().getCategorySelected(categoryName),
              splashRadius: 1,
              checkColor: white,
              hoverColor: HexColor(categoryColor),
              activeColor: HexColor(categoryColor),
              onChanged: (bool? val) => {
                context.read<FilterEventCubbit>().checkCategory(categoryName,val)},
            )): Checkbox(
          value: context.read<FilterEventCubbit>().getCategorySelected(categoryName),
          splashRadius: 1,
          checkColor: white,
          hoverColor: HexColor(categoryColor),
          activeColor: HexColor(categoryColor),

          onChanged: (bool? val) => {
            context.read<FilterEventCubbit>().checkCategory(categoryName,val)},
        )
        ),
            new Text(categoryName.toUpperCase(),
                style: context.read<FilterEventCubbit>().getCategorySelected(categoryName)? subtitle_rev.copyWith(fontSize: this.isWebMode?12:14,color: white) : subtitle.copyWith(fontSize: this.isWebMode?12:14, color: grey)),
          ]), i++)).keys.toList();
  }


  @override
  Widget filterBox(BuildContext context) {
    const double spaceIconText = 10;
    const double spaceInput = 10;
    DateFormat formatDate = DateFormat('d MMM y','it_IT');

    return new Form(
          key: context.read<FilterEventCubbit>().formKey,
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
                      Padding(
                          padding: EdgeInsets.only(top: spaceInput),
                          child: Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.clipboard, color: grey,),
                              SizedBox(width: spaceIconText),
                              Expanded(
                                  child: TextFormField(
                                    cursorColor: white,
                                    controller: context.read<FilterEventCubbit>().titleController,
                                    style: TextStyle(color: white),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                                      hintText: 'Cerca per titolo',
                                      hintStyle: subtitle,
                                      border: InputBorder.none,
                                    ),
                                    onSaved: (value) => context.read<FilterEventCubbit>().state.eventFilter.title = value??"",
                                  )),
                            ],
                          )),
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
                                    controller: context.read<FilterEventCubbit>().addressController,
                                    style: TextStyle(color: white),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                                      hintText: 'Cerca per indirizzo',
                                      hintStyle: subtitle,
                                      border: InputBorder.none,
                                    ),
                                    onSaved: (value) => context.read<FilterEventCubbit>().state.eventFilter.address = value??"",
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
                                    controller: context.read<FilterEventCubbit>().customerController,
                                    cursorColor: white,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(color: white),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                                      hintText: 'Cerca per numero cliente',
                                      hintStyle: subtitle,
                                      border: InputBorder.none,),
                                    onSaved: (value) => context.read<FilterEventCubbit>().state.eventFilter.customer.phone = value??"",
                                  )),
                            ],
                          )),
                      BlocBuilder<FilterEventCubbit, FilterEventState>(
                          buildWhen: (previous, current) => previous.filterStartDate != current.filterStartDate ||  previous.filterEndDate != current.filterEndDate,
                          builder: (context, state) {
                            return Padding(
                                padding: EdgeInsets.only(top: spaceInput),
                                child: Row(
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.calendarAlt, color: grey,),
                                    SizedBox(width: spaceIconText),
                                    Expanded(
                                      child: GestureDetector(
                                        child: Text(context.read<FilterEventCubbit>().state.filterStartDate?
                                        formatDate.format(context.read<FilterEventCubbit>().state.eventFilter.start):'Data inizio',
                                          style: subtitle.copyWith(color: context.read<FilterEventCubbit>().state.filterStartDate?white:grey, fontSize: this.isWebMode?14:16 ),
                                          textAlign: TextAlign.center,),
                                        onTap: () =>
                                            PlatformDatePicker.selectDate(context,
                                              maxTime: DateTime(3000),
                                              currentTime: context.read<FilterEventCubbit>().state.eventFilter.start,
                                              onConfirm: (date) => context.read<FilterEventCubbit>().setStartDate(date),
                                            ),
                                      ),),
                                    IconButton(
                                        icon: Icon(Icons.clear, size: 16, color: grey),
                                        onPressed: () {
                                          context.read<FilterEventCubbit>().clearStartDate();
                                        }
                                    ),
                                    SizedBox(width: 10),
                                    Text('-', style: subtitle.copyWith(color: grey), textAlign: TextAlign.center,),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        child: Text(context.read<FilterEventCubbit>().state.filterEndDate?
                                        formatDate.format(context.read<FilterEventCubbit>().state.eventFilter.end):'Data fine',
                                          style: subtitle.copyWith(color: context.read<FilterEventCubbit>().state.filterEndDate?white:grey),
                                          textAlign: TextAlign.center,),
                                        onTap: () =>
                                            PlatformDatePicker.selectDate(context,
                                              minTime: TimeUtils.truncateDate(context.read<FilterEventCubbit>().state.eventFilter.start, "day"),
                                              maxTime: DateTime(3000),
                                              currentTime: context.read<FilterEventCubbit>().state.eventFilter.start,
                                              onConfirm: (date) => context.read<FilterEventCubbit>().setEndDate(date),
                                            ),
                                      ),),
                                    IconButton(
                                        icon: Icon(Icons.clear, size: 16,color: grey),
                                        onPressed: () {
                                          context.read<FilterEventCubbit>().clearEndDate();
                                        }
                                    ),

                                  ],
                                ));}),
                      isSupervisor? Row(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.hardHat, color: grey,),
                          SizedBox(width: 5),
                          Expanded(
                              child: Text("Operatori", style: subtitle.copyWith(color: grey))),
                          IconButton(
                              icon: Icon(Icons.add, color: grey),
                              onPressed: () {
                                context.read<FilterEventCubbit>().addOperatorDialog(context);
                              }
                          )
                        ],
                      ): Container(),
                      BlocBuilder<FilterEventCubbit, FilterEventState>(
                          buildWhen: (previous, current) => previous.eventFilter.suboperators.toString() != current.eventFilter.suboperators.toString(),
                          builder: (context, state) {
                            return OperatorsList(
                              canRemove: (Account operator) => true,
                              closeFunction: context.read<FilterEventCubbit>().removeOperatorFromEventList,
                              operators: context.read<FilterEventCubbit>().state.eventFilter.suboperators,
                              darkMode: true,
                              isWebMode: true,
                            );}),
                      Text('Tipologia', style: subtitle.copyWith(color: white),),
                      Container(
                          height: isWebMode?120:100,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Center(
                              child: BlocBuilder<FilterEventCubbit, FilterEventState>(
                                  buildWhen: (previous, current) => previous.categorySelected != current.categorySelected ,
                                  builder: (context, state) {
                                    return GridView(
                                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: isWebMode?110:150.0,
                                        mainAxisSpacing: isWebMode?1.0:10.0,
                                        crossAxisSpacing: isWebMode?1.0:10.0,
                                        childAspectRatio: isWebMode?1.0:3/2,
                                        mainAxisExtent: isWebMode?50:80,
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
  void clearFilters(BuildContext context) {
    context.read<FilterEventCubbit>().clearFilter();
    this.clearFilter();
  }

  @override
  void filterValues(BuildContext context){
    context.read<FilterEventCubbit>().filterValue(filterEvent);
  }

  @override
  Widget build(BuildContext context) {
    CloudFirestoreService repository = RepositoryProvider.of<
        CloudFirestoreService>(context);

    return new BlocProvider(
      create: (_) => FilterEventCubbit(repository),
      child: BlocBuilder<FilterEventCubbit, FilterEventState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            this.isSupervisor = context.select((AuthenticationBloc bloc)=>bloc.account!).supervisor;
            super.showFiltersBox = context.read<FilterEventCubbit>().showFiltersBox;
            super.filtersBoxVisibile = state.filtersBoxVisibile;
            super.onSearchChanged = (text) => context.read<FilterEventCubbit>().onSearchChanged(text, this.filterEvent);
            super.enableSearchField = state.enableSearchField;
            if(!state.isLoading()){
                return !isWebMode?Padding(padding: EdgeInsets.only(top: 25),
                  child: super.build(context),): super.build(context);
            } else return LoadingScreen();
          }
      ),);
  }




}