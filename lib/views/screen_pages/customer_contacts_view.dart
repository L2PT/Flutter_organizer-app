import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/cubit/customer_contacts/customer_contacts_cubit.dart';
import 'package:venturiautospurghi/cubit/web/web_cubit.dart';
import 'package:venturiautospurghi/models/customer.dart';
import 'package:venturiautospurghi/models/filter_wrapper.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/create_entity_utils.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/alert/alert_success.dart';
import 'package:venturiautospurghi/views/widgets/card_customer_widget.dart';
import 'package:venturiautospurghi/views/widgets/filter/filter_customer_widget.dart';
import 'package:venturiautospurghi/views/widgets/responsive_widget.dart';

class CustomerContacts extends StatelessWidget {

  Map<String, dynamic> filters;
  Future<List<Customer>> Function(Map<String, FilterWrapper> filters)? onFiltersChanged;

  CustomerContacts({Map<String, dynamic>? filters}) :
        this.filters = filters??{};

  @override
  Widget build(BuildContext context) {
    CloudFirestoreService repository = context.read<CloudFirestoreService>();

    return new BlocProvider(
        create: (_) => CustomerContactsCubit(repository, filters),
        child: ResponsiveWidget(
          smallScreen: _smallScreen(),
          largeScreen: _largeScreen(),
        ));
  }
}

void _onDeletePressed(Customer customer, BuildContext context) async {
  if (await context.read<CustomerContactsCubit>().deleteCustomer(customer))
    await SuccessAlert(context, text: "Cliente eliminato!").show();
}

void scrollListener(BuildContext context){
  context.read<CustomerContactsCubit>().scrollController.addListener(() {
    if (context.read<CustomerContactsCubit>().scrollController.position.pixels == context.read<CustomerContactsCubit>().scrollController.position.maxScrollExtent) {
      if(context.read<CustomerContactsCubit>().canLoadMore)
        context.read<CustomerContactsCubit>().loadMoreData();
    }
  });
}


class _largeScreen extends StatefulWidget {

  _largeScreen();

  @override
  State<StatefulWidget> createState() => _largeScreenState();

}

class _largeScreenState extends State<_largeScreen>  {

  @override
  void initState() {
    scrollListener(context);
  }

  Widget gridContactsCustomer() =>  Container(
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    child:Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 5,),
                Text("Tutti i clienti ", style: title, textAlign: TextAlign.left,),
                SizedBox(height: 10,),
                context.read<CustomerContactsCubit>().state.customerList.length>0 ? //TODO add pagination here
                Container(
                    height: MediaQuery.of(context).size.height - 110,
                    child: GridView(
                        controller: context.read<CustomerContactsCubit>().scrollController,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 350.0,
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 5.0,
                          childAspectRatio: 1.10,
                        ),
                        children: context.read<CustomerContactsCubit>().state.customerList.map((customer)=>  Container(
                            child: CardCustomer(
                              paddingTopHeader: 10,
                              cardMode: true,
                              customer:  customer,
                              onEditAction: () => PlatformUtils.navigator(context, Constants.createCustomerViewRoute,<String, dynamic>{
                                'objectParameter' : context.read<CustomerContactsCubit>().getEventCustomer(customer),
                                'typeStatus' : TypeStatus.modify}),
                              onDeleteAction: () => _onDeletePressed(customer, context),)
                        )).toList()
                    )): Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(bottom: 5) ,child:Text("Nessun cliente da mostrare",style: title,)),
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

  @override
  Widget build(BuildContext context) {

    return BlocBuilder <CustomerContactsCubit, CustomerContactsState>(
        builder: (context, state) {
          return !(state is ReadyCustomerContacts) ? Center(child: CircularProgressIndicator()) :
          BlocBuilder<WebCubit, WebCubitState>(
              buildWhen: (previous, current) => previous.customerList != current.customerList,
          builder: (context, state) {
                if(state.filterCustomer)
                  context.read<CustomerContactsCubit>().updateCustomerList(state.customerList);
                return gridContactsCustomer();
          });
        });
  }

  @override
  void dispose() {
    context.read<CustomerContactsCubit>().scrollController.dispose();
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
    scrollListener(context);
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
          CustomersFilterWidget(
            hintTextSearch: 'Cerca i clienti',
            onSearchFieldChanged: context.read<CustomerContactsCubit>().onFiltersChanged,
            onFiltersChanged: context.read<CustomerContactsCubit>().onFiltersChanged,
          ),
          BlocBuilder<CustomerContactsCubit, CustomerContactsState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                return !(state is ReadyCustomerContacts) ? Center(
                    child: CircularProgressIndicator()) : state.customerList.length > 0 ?
                Expanded(child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: ListView.separated(
                        controller: context.read<CustomerContactsCubit>().scrollController,
                        separatorBuilder: (context, index) => SizedBox(height: 10,),
                        physics: BouncingScrollPhysics(),
                        padding: new EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: state.customerList.length+1,
                        itemBuilder: (context, index) => index != state.customerList.length?
                        Container(
                            child: CardCustomer(
                                customer:  state.customerList[index],
                                onEditAction: () => PlatformUtils.navigator(context, Constants.createCustomerViewRoute,<String, dynamic>{
                                  'objectParameter' : context.read<CustomerContactsCubit>().getEventCustomer(state.customerList[index]),
                                  'typeStatus' : TypeStatus.modify}),
                                onDeleteAction: () => _onDeletePressed(state.customerList[index], context),)
                        ) : context.read<CustomerContactsCubit>().canLoadMore?
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
                            "Nessun cliente da mostrare", style: title,)),
                    ],
                  ),
                );
              })
        ],
      ),);
  }

  @override
  void dispose() {
    context.read<CustomerContactsCubit>().scrollController.dispose();
    super.dispose();
  }

}