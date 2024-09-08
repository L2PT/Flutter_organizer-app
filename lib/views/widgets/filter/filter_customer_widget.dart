import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/cubit/filter_customers/customer_filter_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/filter_wrapper.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/filter/filter_widget.dart';

class CustomersFilterWidget extends FilterWidget {

  final Function callbackFiltersChanged;
  final Function callbackSearchFieldChanged;
  final double maxHeightContainerExpanded;

  CustomersFilterWidget({
    double paddingTop = 20,
    double paddingTopBox = 16,
    double paddingLeftBox = 14,
    double paddingBottomBox = 14,
    double paddingRightBox = 14,
    double spaceButton = 15,
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
          textSearchFieldVisible: textSearchFieldVisible,
          paddingTop: paddingTop,
          paddingTopBox: paddingTopBox,
          paddingLeftBox: paddingLeftBox,
          paddingBottomBox: paddingBottomBox,
          paddingRightBox: paddingRightBox,
          spaceButton: spaceButton,
      );

  @override
  Widget filterBox(BuildContext context) {
    const double spaceIconText = 10;
    const double spaceInput = 10;

    return new Form(
        key: context.read<CustomerFilterCubit>().formKey,
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
                            Icon(Icons.assignment_ind, color: grey,),
                            SizedBox(width: spaceIconText),
                            Expanded(
                                child: TextFormField(
                                  cursorColor: white,
                                  controller: context.read<CustomerFilterCubit>().titleController,
                                  style: TextStyle(color: white),
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                                    hintText: 'Cerca per nome e cognome',
                                    hintStyle: subtitle,
                                    border: InputBorder.none,
                                  ),
                                  onSaved: (value) => context.read<CustomerFilterCubit>().state.filters["name-surname"]!.fieldValue = value??"",
                                )),
                          ],
                        )): Container(),
                    Padding(
                        padding: EdgeInsets.only(top: spaceInput),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.mail, color: grey,),
                            SizedBox(width: spaceIconText),
                            Expanded(
                                child: TextFormField(
                                  controller: context.read<CustomerFilterCubit>().emailController,
                                  cursorColor: white,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(color: white),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                                    hintText: 'Cerca per mail',
                                    hintStyle: subtitle,
                                    border: InputBorder.none,),
                                  onSaved: (value) => context.read<CustomerFilterCubit>().state.filters["email"]!.fieldValue = value??"",
                                )),
                          ],
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: spaceInput),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.phone, color: grey,),
                            SizedBox(width: spaceIconText),
                            Expanded(
                                child: TextFormField(
                                  controller: context.read<CustomerFilterCubit>().phoneController,
                                  cursorColor: white,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(color: white),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                                    hintText: 'Cerca per telefono',
                                    hintStyle: subtitle,
                                    border: InputBorder.none,),
                                  onSaved: (value) => context.read<CustomerFilterCubit>().state.filters["phone"]!.fieldValue = value??"",
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
                                  controller: context.read<CustomerFilterCubit>().addressController,
                                  style: TextStyle(color: white),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                                    hintText: 'Cerca per indirizzo',
                                    hintStyle: subtitle,
                                    border: InputBorder.none,
                                  ),
                                  onSaved: (value) => context.read<CustomerFilterCubit>().state.filters["address"]!.fieldValue = value??"",
                                )),
                          ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: spaceInput),
                      child: Row(
                          children: <Widget>[
                            Icon(Icons.apartment, color: grey,),
                            SizedBox(width: spaceIconText),
                            Expanded(
                              child: Text("Azienda", style: subtitle.copyWith(color: grey),),
                            ),
                            Container(
                                height: 30,
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child:Switch(
                                    inactiveTrackColor: black_light,
                                    value: context.read<CustomerFilterCubit>().state.isCompany,
                                    activeTrackColor: black_light,
                                    activeColor: yellow,
                                    onChanged: context.read<CustomerFilterCubit>().setIsCompany,
                                  ),
                                ),
                            ),
                          ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: spaceInput),
                      child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.userTie, color: grey,),
                            SizedBox(width: spaceIconText),
                            Expanded(
                              child: Text("Privato", style: subtitle.copyWith(color: grey),),
                            ),
                            Container(
                              height: 30,
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child:Switch(
                                  inactiveTrackColor: black_light,
                                  value: context.read<CustomerFilterCubit>().state.isPrivate,
                                  activeTrackColor: black_light,
                                  activeColor: yellow,
                                  onChanged: context.read<CustomerFilterCubit>().setIsPrivate,
                                ),
                              ),
                            ),
                          ]),
                    ),
                    context.read<CustomerFilterCubit>().state.isCompany?
                    Padding(
                      padding: EdgeInsets.only(top: spaceInput),
                      child: Row(
                          children: <Widget>[
                            Icon(Icons.assignment, color: grey,),
                            SizedBox(width: spaceIconText),
                            Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  cursorColor: white,
                                  controller: context.read<CustomerFilterCubit>().paritaivaController,
                                  style: TextStyle(color: white),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                                    hintText: 'Cerca per partita iva',
                                    hintStyle: subtitle,
                                    border: InputBorder.none,
                                  ),
                                  onSaved: (value) => context.read<CustomerFilterCubit>().state.filters["partitaIva"]!.fieldValue = value??"",
                                )),
                          ]),
                    ):Container(),
                    context.read<CustomerFilterCubit>().state.isPrivate?
                    Padding(
                      padding: EdgeInsets.only(top: spaceInput),
                      child: Row(
                          children: <Widget>[
                            Icon(Icons.badge, color: grey,),
                            SizedBox(width: spaceIconText),
                            Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  cursorColor: white,
                                  controller: context.read<CustomerFilterCubit>().codicefiscaleController,
                                  style: TextStyle(color: white),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 5),
                                    hintText: 'Cerca per codice fiscale',
                                    hintStyle: subtitle,
                                    border: InputBorder.none,
                                  ),
                                  onSaved: (value) => context.read<CustomerFilterCubit>().state.filters["codFiscale"]!.fieldValue = value??"",
                                )),
                          ]),
                    ):Container(),
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
    context.read<CustomerFilterCubit>().onSearchFieldTextChanged(text);
  }

  @override
  void clearFilters(BuildContext context) {
    context.read<CustomerFilterCubit>().clearFilters();
  }

  @override
  void applyFilters(BuildContext context){
    context.read<CustomerFilterCubit>().notifyFiltersChanged(true);
  }

  @override
  TextEditingController titleController(BuildContext context) => context.read<CustomerFilterCubit>().titleController;


  @override
  Widget build(BuildContext context) {
    CloudFirestoreService repository = context.read<CloudFirestoreService>();
    Account account = context.read<AuthenticationBloc>().account!;

    return new BlocProvider(
      create: (_) => CustomerFilterCubit(repository, callbackSearchFieldChanged, callbackFiltersChanged),
      child: BlocBuilder<CustomerFilterCubit, CustomersFilterState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            super.showFiltersBox = context.read<CustomerFilterCubit>().showFiltersBox;
            super.filtersBoxVisibile = state.filtersBoxVisibile;
            if(!state.isLoading()){
              return !textSearchFieldVisible?
              Padding(
                padding: EdgeInsets.only(top: paddingTop),
                child: super.build(context),
              ): super.build(context);
            } else return CircularProgressIndicator();
          }
      ),);
  }

}