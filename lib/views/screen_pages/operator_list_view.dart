import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/operator_list/operator_list_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/filter_operators_widget.dart';
import 'package:venturiautospurghi/views/widgets/list_tile_operator.dart';

class OperatorList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var repository = context.read<CloudFirestoreService>();

    Widget content = Column(
      children: <Widget>[
        SizedBox(height: 8.0),
        logo,
        SizedBox(height: 8.0),
        BlocBuilder<OperatorListCubit, OperatorListState>(builder: (context, state) {
          return OperatorsFilterWidget(
            onSearchDateChanged: context.read<OperatorListCubit>().onSearchDateChanged,
            onSearchTimeChanged: context.read<OperatorListCubit>().onSearchTimeChanged,
            searchTimeField: context.read<OperatorListCubit>().state.searchTimeField,
            filtersBoxVisibile: context.read<OperatorListCubit>().state.filtersBoxVisibile,
            showFiltersBox: context.read<OperatorListCubit>().showFiltersBox,
            onSearchChanged: context.read<OperatorListCubit>().onSearchNameChanged,
            hintTextSearch: "Cerca un operatore",
          );
        }),
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

class _operatorList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _operatorListState();

}

class _operatorListState extends State<_operatorList> {
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if(context.read<OperatorListCubit>().canLoadMore)
          context.read<OperatorListCubit>().loadMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    onTileTap(Account operator) {
      context.read<MobileBloc>().add(NavigateEvent(Constants.dailyCalendarRoute, {"operator":operator}));
    }

    Widget buildOperatorList() => ListView.separated(
      controller: _scrollController,
      separatorBuilder: (context, index) =>
          Divider(height: 2, thickness: 1, indent: 15, endIndent: 15, color: grey_light),
      physics: BouncingScrollPhysics(),
      padding: new EdgeInsets.symmetric(vertical: 8.0),
      itemCount: (context.read<OperatorListCubit>().state as ReadyOperators).filteredOperators.length+1,
      itemBuilder: (context, index) => index != (context.read<OperatorListCubit>().state as ReadyOperators).filteredOperators.length?
        new ListTileOperator((context.read<OperatorListCubit>().state as ReadyOperators).filteredOperators[index], onTap: onTileTap) :
      context.read<OperatorListCubit>().canLoadMore?Center(
          child: Container(
            margin: new EdgeInsets.symmetric(vertical: 13.0),
            height: 26,
            width: 26,
            child: CircularProgressIndicator(),
          )):Container()
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


}