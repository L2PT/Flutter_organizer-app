import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/operator_list/operator_list_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/list_tile_operator.dart';
import 'package:venturiautospurghi/views/widgets/platform_datepicker.dart';

class OperatorList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var repository = context.read<CloudFirestoreService>();

    Widget content = Column(
      children: <Widget>[
        SizedBox(height: 8.0),
        logo,
        SizedBox(height: 8.0),
        _searchBar(),
        SizedBox(height: 8.0),
        _filtersBox(),
        Container(
          margin: EdgeInsets.only(left: 15, top: 10, bottom: 5),
          alignment: Alignment.centerLeft,
          child: Text("Tutti gli operatori", style: subtitle.copyWith(fontWeight: FontWeight.bold, color: black ),),
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

    return BlocBuilder<OperatorListCubit, OperatorListState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DecoratedBox(
                decoration: BoxDecoration(
                    color: black, borderRadius: BorderRadius.all(Radius.circular(15.0))),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: context.read<OperatorListCubit>().onSearchNameChanged,
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
                        icon: new Icon((!context.read<OperatorListCubit>().state.filtersBoxVisibile) ? Icons.tune : Icons.keyboard_arrow_up, color: white),
                        onPressed: context.read<OperatorListCubit>().showFiltersBox
                    ),
                  ],
                )));
      },
    );
  }

}

class _filtersBox extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OperatorListCubit, OperatorListState>(builder: (context, state) {
      return (state.filtersBoxVisibile)
          ? Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              padding: const EdgeInsets.only(top: 16.0, right: 14.0, bottom: 14.0, left: 14.0),
              decoration: BoxDecoration(color: black, borderRadius: BorderRadius.all(Radius.circular(15.0))),
              child: Column(children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.tune),
                    SizedBox( width: 5,),
                    Text("FILTRA PER OPEARATORI LIBERI", style: subtitle_rev),
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.date_range),
                        SizedBox(width: 5),
                        Expanded(
                          child: GestureDetector(
                            child: Text(
                              context.read<OperatorListCubit>().state.searchTimeField.toString().split(' ').first,
                              style: title_rev),
                            onTap: () =>
                              PlatformDatePicker.selectDate(context,
                                maxTime: DateTime(3000),
                                currentTime: context.read<OperatorListCubit>().state.searchTimeField,
                                onConfirm: (date) => context.read<OperatorListCubit>().onSearchDateChanged(date),
                              ),
                        )),
                        Icon(Icons.watch_later),
                        SizedBox(width: 5),
                        Expanded(
                          child: GestureDetector(
                            child: Text(context.read<OperatorListCubit>().state.searchTimeField.toString().split(' ').last.split('.').first.substring(0, 5),
                              style: title_rev),
                            onTap: () => PlatformDatePicker.selectTime(context,
                              currentTime: context.read<OperatorListCubit>().state.searchTimeField,
                              onConfirm: (date) => context.read<OperatorListCubit>().onSearchTimeChanged(date),
                            ),
                        ))
                      ],
                    ))
              ]))
          : Container();
    });
  }
}

class _operatorList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    onTileTap(Account operator) {
      context.read<MobileBloc>().add(NavigateEvent(Constants.dailyCalendarRoute, {"operator":operator}));
    }

    Widget buildOperatorList() => ListView.separated(
      separatorBuilder: (context, index) =>
          Divider(height: 2, thickness: 1, indent: 15, endIndent: 15, color: grey_light),
      physics: BouncingScrollPhysics(),
      padding: new EdgeInsets.symmetric(vertical: 8.0),
      itemCount: (context.read<OperatorListCubit>().state as ReadyOperators).filteredOperators.length,
      itemBuilder: (context, index) =>
      new ListTileOperator((context.read<OperatorListCubit>().state as ReadyOperators).filteredOperators[index], onTap: onTileTap),
    );

    return BlocBuilder<OperatorListCubit, OperatorListState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return (state is ReadyOperators)? new Expanded(
            child: buildOperatorList()
        ) : CircularProgressIndicator();
      },
    );
  }

}