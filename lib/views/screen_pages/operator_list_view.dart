import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/operator_list/operator_list_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/list_tile_operator.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';

class OperatorList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var repository = RepositoryProvider.of<CloudFirestoreService>(context);

    Widget content = Column(
      children: <Widget>[
        SizedBox(height: 8.0),
        logo,
        SizedBox(height: 8.0),
        _searchBar(),
        SizedBox(height: 8.0),
        _filtersBox(),
        Container(
          margin: EdgeInsets.only(left: 15),
          alignment: Alignment.centerLeft,
          child: Text("Tutti gli operatori liberi", style: label.copyWith(fontWeight: FontWeight.bold),),
        ),
        _operatorList()
      ],
    );

    return new BlocProvider(
        create: (_) => OperatorListCubit(repository),
        child: Material(
            elevation: 12.0,
            borderRadius: new BorderRadius.only(
                topLeft: new Radius.circular(16.0),
                topRight: new Radius.circular(16.0)),
            child: content
        )
    );
  }
}

class _searchBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Widget searchField = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: black, borderRadius: BorderRadius.all(Radius.circular(15.0))),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    onChanged: context.bloc<OperatorListCubit>().onSearchNameChanged,
                    style: new TextStyle(color: white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: new Icon(
                        Icons.search,
                        color: white,
                      ),
                      hintText: "Cerca un operatore",
                    ),
                  ),
                ),
                IconButton(
                    icon: new Icon((!context.bloc<OperatorListCubit>().state.filtersBoxVisibile) ? Icons.tune : Icons.keyboard_arrow_up, color: white),
                    onPressed: context.bloc<OperatorListCubit>().showFiltersBox
                ),
              ],
            )));

    return BlocBuilder<OperatorListCubit, OperatorListState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return searchField;
      },
    );
  }

}

class _filtersBox extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.only(
            top: 16.0, right: 14.0, bottom: 4.0, left: 14.0),
        decoration: BoxDecoration(
            color: black, borderRadius: BorderRadius.all(Radius.circular(15.0))),
        child: Column(children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.tune),
              SizedBox(width: 5,),
              Text("FILTRA PER OPEARATORI LIBERI", style: subtitle_rev),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.date_range),
                  Expanded(
                      child: GestureDetector(
                        child: TextFormField(
                          enabled: false,
                          cursorColor: black,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              hintText: '01 Sett ' + DateTime
                                  .now()
                                  .year
                                  .toString(), hintStyle: label, border: InputBorder.none
                          ),
                          style: title,
                          initialValue: TimeUtils.truncateDate(context.bloc<OperatorListCubit>().state.searchTimeField, "day").toString(),
                        ),
                        onTap: () =>
                            DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              currentTime: context.bloc<OperatorListCubit>().state.searchTimeField,
                              locale: LocaleType.it,
                              onConfirm: (date) => context.bloc<OperatorListCubit>().onSearchDateChanged(date),
                            ),
                      )),
                  Icon(Icons.watch_later),
                  Expanded(
                      child: GestureDetector(
                        child: TextFormField(
                          enabled: false,
                          cursorColor: black,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              hintText: '10:00', hintStyle: label, border: InputBorder.none
                          ),
                          style: title,
                          initialValue: context.bloc<OperatorListCubit>().state.searchTimeField.hour.toString() + " " + context.bloc<OperatorListCubit>().state.searchTimeField.minute.toString(),
                        ),
                        onTap: () =>
                            DatePicker.showTimePicker(context,
                              showTitleActions: true,
                              currentTime: context.bloc<OperatorListCubit>().state.searchTimeField,
                              locale: LocaleType.it,
                              onConfirm: (date) => context.bloc<OperatorListCubit>().onSearchDateChanged(date),
                            ),
                      ))
                ],
              )),
        ]));
  }
}

class _operatorList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    onTileTap(Account operator) {
      context.bloc<MobileBloc>().add(NavigateEvent(Constants.dailyCalendarRoute, [operator, null]));
    }

    Widget buildOperatorList = ListView.separated(
      separatorBuilder: (context, index) =>
          Divider(height: 2, thickness: 1, indent: 15, endIndent: 15, color: grey_light),
      physics: BouncingScrollPhysics(),
      padding: new EdgeInsets.symmetric(vertical: 8.0),
      itemCount: (context.bloc<OperatorListCubit>().state as ReadyOperators).filteredOperators.length,
      itemBuilder: (context, index) =>
      new ListTileOperator((context.bloc<OperatorListCubit>().state as ReadyOperators).filteredOperators[index], onTap: onTileTap),
    );

    return BlocBuilder<OperatorListCubit, OperatorListState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return (state is ReadyOperators)? new Expanded(
            child: buildOperatorList
        ) : LoadingScreen();
      },
    );
  }

}