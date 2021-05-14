import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venturiautospurghi/cubit/filter_events/filter_events_cubit.dart';
import 'package:venturiautospurghi/plugins/dispatcher/mobile.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/views/widgets/responsive_widget.dart';

class FilterWidget extends StatelessWidget {

  bool filtersBoxVisibile;
  void Function()? showFiltersBox;
  final TextEditingController titleController = new TextEditingController();
  final String hintTextSearchField;
  final bool showActionFilters;
  bool isExpandable;
  late bool largeScreen;


  FilterWidget({
    required this.filtersBoxVisibile,
    this.showFiltersBox,
    required this.isExpandable,
    required this.hintTextSearchField,
    this.showActionFilters = true,
  });

  @override
  Widget build(BuildContext context) {
    largeScreen = !ResponsiveWidget.isSmallScreen(context);

    Widget MobileFilter() {
      return Column(
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: this.filterAlwaysVisibleBox(context),),
          SizedBox(height: 8.0),
          this.filtersBoxVisibile ? Container(
              margin: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 16.0),
              padding: const EdgeInsets.only(
                  top: 16.0, right: 14.0, bottom: 14.0, left: 14.0),
              decoration: BoxDecoration(color: black,
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              child: Column(
                children: [
                  this.filterBox(context),
                  SizedBox(height: 10.0),
                  this.showActionFilters ? this.actionFilter(context) : Container(),
                ],
              ))
              : Container(),
        ],);
    }

    Widget WebFilter() {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          padding: const EdgeInsets.only(
              top: 16.0, right: 14.0, bottom: 14.0, left: 14.0),
          decoration: BoxDecoration(
              color: black,
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: Column(
            children: [
              this.filterBox(context),
              SizedBox(height: 10.0),
              this.showActionFilters ? this.actionFilter(context) : Container(),
            ],
          ));
    }

    return PlatformUtils.isMobile?MobileFilter():WebFilter();

  }

  Widget filterBox(BuildContext context){
    return Column();
  }

  Widget filterAlwaysVisibleBox(BuildContext context){
    return DecoratedBox(
        decoration: BoxDecoration(
            color: black, borderRadius: BorderRadius.all(Radius.circular(15.0))),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: titleController,
                onChanged: (s)=>onSearchFieldTextChanged(context,s),
                style: new TextStyle(color: white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: new Icon(
                    Icons.search,
                    color: white,
                  ),
                  hintText: hintTextSearchField,
                ),
              ),
            ),
            isExpandable?IconButton(
                icon: new Icon((!filtersBoxVisibile) ? Icons.tune : Icons.keyboard_arrow_up, color: white),
                onPressed: showFiltersBox
            ):Container(),
          ],
        )
    );
  }

  Widget actionFilter(BuildContext context){
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: new Text('Annulla', style: label_rev,),
            onPressed: () => this.clearFilters(context),
          ),
          SizedBox(width: 15,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(side: BorderSide(width: 1.0, color: white,)),
            child: new Text('FILTRA', style: button_card),
            onPressed: () => this.applyFilters(context),
          ),
        ],
   );

  }

  void onSearchFieldTextChanged(BuildContext context, String text){}

  void clearFilters(BuildContext context){}

  void applyFilters(BuildContext context){}

}