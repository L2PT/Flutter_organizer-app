//import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
//import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:venturiautospurghi/bloc/backdrop_bloc/backdrop_bloc.dart';
//import 'package:venturiautospurghi/bloc/operators_bloc/operators_bloc.dart';
//import 'package:venturiautospurghi/models/account.dart';
//import 'package:venturiautospurghi/utils/global_methods.dart';
//import 'package:venturiautospurghi/utils/global_contants.dart' as global;
//import 'package:venturiautospurghi/utils/theme.dart';
//import 'file:///C:/Users/Gio/Desktop/Flutter_organizer-app/lib/view/widget/splash_screen.dart';
//
//class OperatorList extends StatefulWidget {
//  OperatorList({Key key}) : super(key: key);
//
//  @override
//  _OperatorListState createState() => new _OperatorListState();
//}
//
//class _OperatorListState extends State<OperatorList> {
//  final dateFormat = DateFormat("dd-MM-yy");
//  final timeFormat = DateFormat("h:mm a");
//  final _filtersKey = new GlobalKey<FormState>();
//  final TextEditingController _stringFilter = new TextEditingController();
//  DateTime _dateFilter = TimeUtils.truncateDate(DateTime.now(), "day");
//  bool _filters = false;
//  bool ready = false;
//
//  _SearchListState() {
//    _stringFilter.text = BlocProvider.of<OperatorsBloc>(context).stringQuery;
//    _stringFilter.addListener(() {
//      if (_stringFilter.text.isEmpty) {
//        BlocProvider.of<OperatorsBloc>(context).add(ApplyOperatorFilterString(null));
//      } else {
//        BlocProvider.of<OperatorsBloc>(context).add(ApplyOperatorFilterString(_stringFilter.text));
//      }
//    });
//  }
//
//  @override
//  void initState() {
//    _SearchListState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return BlocBuilder<OperatorsBloc, OperatorsState>(
//        builder: (context, state) {
//      if (state is Loaded) {
//        //get data
//        BlocProvider.of<OperatorsBloc>(context).add(ApplyOperatorFilters(null, null));
//        ready = true;
//      } else if (state is Filtered && ready) {
//        return Material(
//            elevation: 12.0,
//            borderRadius: new BorderRadius.only(
//                topLeft: new Radius.circular(16.0),
//                topRight: new Radius.circular(16.0)),
//            child: Column(
//              children: <Widget>[
//                SizedBox(height: 8.0),
//                logo,
//                Padding(padding: const EdgeInsets.all(8.0), child: searchBar()),
//                Visibility(
//                  child: filtersBox(),
//                  visible: _filters,
//                ),
//                Container(
//                  margin: EdgeInsets.only(left: 15),
//                  alignment: Alignment.centerLeft,
//                  child: Text("Tutti gli operatori liberi", style: label.copyWith(fontWeight: FontWeight.bold),),
//                ),
//                Expanded(
//                  child: ListView.separated(
//                    separatorBuilder: (context, index) => Divider(
//                      height: 2,
//                      thickness: 1,
//                      indent: 15,
//                      endIndent: 15,
//                      color: grey_light,
//                    ),
//                    physics: BouncingScrollPhysics(),
//                    padding: new EdgeInsets.symmetric(vertical: 8.0),
//                    itemCount: state.operators.length,
//                    itemBuilder: (context, index) =>
//                        new ChildItem(state.operators[index]),
//                  ),
//                ),
//              ],
//            ));
//      }
//      return LoadingScreen();
//    });
//  }
//
//  Widget searchBar() {
//    return DecoratedBox(
//        decoration: BoxDecoration(
//            color: black, borderRadius: BorderRadius.all(Radius.circular(15.0))),
//        child: Row(
//          children: <Widget>[
//            Expanded(
//              child: TextField(
//                style: new TextStyle(color: white),
//                controller: _stringFilter,
//                decoration: InputDecoration(
//                  border: InputBorder.none,
//                  prefixIcon: new Icon(
//                    Icons.search,
//                    color: white,
//                  ),
//                  hintText: "Cerca un operatore",
//                ),
//              ),
//            ),
//            IconButton(
//              icon: new Icon((!_filters) ? Icons.tune : Icons.keyboard_arrow_up,
//                  color: white),
//              onPressed: () {
//                setState(() {
//                  _filters = !_filters;
//                });
//              },
//            ),
//          ],
//        ));
//  }
//
//  Widget filtersBox() {
//    return Container(
//        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//        padding: const EdgeInsets.only(
//            top: 16.0, right: 14.0, bottom: 4.0, left: 14.0),
//        decoration: BoxDecoration(
//            color: black, borderRadius: BorderRadius.all(Radius.circular(15.0))),
//        child: Column(children: <Widget>[
//          Row(
//            children: <Widget>[
//              Icon(Icons.tune),
//              SizedBox(width: 5,),
//              Text("FILTRA PER OPEARATORI LIBERI", style: subtitle_rev),
//            ],
//          ),
//          Padding(
//              padding: EdgeInsets.only(top: 5.0),
//              child: new Form(
//                  key: this._filtersKey,
//                  child: Row(
//                    children: <Widget>[
//                      Icon(Icons.date_range),
//                      Expanded(
//                          child: DateTimeField(
//                        decoration: InputDecoration(
//                            border: OutlineInputBorder(
//                                borderSide: BorderSide(
//                                    width: 0.0, style: BorderStyle.none))),
//                        style: subtitle_rev,
//                        resetIcon: Icon(
//                          Icons.clear,
//                          color: white,
//                        ),
//                        format: dateFormat,
//                        initialValue: _dateFilter,
//                        enabled: true,
//                        readOnly: true,
//                        onShowPicker: (context, currentValue) {
//                          return showDatePicker(
//                              context: context,
//                              firstDate:
//                                  TimeUtils.truncateDate(DateTime.now(), "day"),
//                              initialDate: currentValue != null
//                                  ? currentValue.year > 2000
//                                      ? currentValue
//                                      : DateTime(
//                                          2000 + currentValue.year,
//                                          currentValue.month,
//                                          currentValue.day,
//                                          currentValue.hour,
//                                          currentValue.minute)
//                                  : TimeUtils.truncateDate(DateTime.now(), "day"),
//                              lastDate: DateTime(3000));
//                        },
//                        onChanged: (v) {
//                          print(v);
//                        },
//                        onSaved: (DateTime value) => _dateFilter = value != null
//                            ? value.year > 2000
//                                ? value
//                                : DateTime(2000 + value.year, value.month,
//                                    value.day, value.hour, value.minute)
//                            : null,
//                      )),
//                      Icon(Icons.watch_later),
//                      Expanded(
//                        child: DateTimeField(
//                            decoration: InputDecoration(
//                                border: OutlineInputBorder(
//                                    borderSide: BorderSide(
//                                        width: 0.0, style: BorderStyle.none))),
//                            style: subtitle_rev,
//                            resetIcon: Icon(
//                              Icons.clear,
//                              color: white,
//                            ),
//                            format: timeFormat,
//                            initialValue: DateTime(0),
//                            enabled: true,
//                            readOnly: true,
//                            onShowPicker: (context, currentValue) async {
//                              final time = await showTimePicker(
//                                context: context,
//                                initialTime: TimeOfDay.fromDateTime(
//                                    currentValue ?? DateTime(0)),
//                              );
//                              return DateTimeField.convert(time);
//                            },
//                            onSaved: (DateTime value) => _dateFilter =
//                                _dateFilter != null
//                                    ? value != null
//                                        ? _dateFilter.add(Duration(
//                                            hours: value.hour,
//                                            minutes: value.minute))
//                                        : _dateFilter
//                                    : null),
//                      ),
//                    ],
//                  ))),
//          Align(
//              alignment: Alignment.bottomRight,
//              child: RaisedButton(
//                child: new Text('FILTRA', style: subtitle_rev),
//                shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
//                elevation: 15,
//                onPressed: () => _applyFilters(),
//              ))
//        ]));
//  }
//
//  Future _applyFilters() async {
//    if (this._filtersKey.currentState.validate()) {
//      _filtersKey.currentState.save();
//      _filters = false;
//      print(_dateFilter);
//      BlocProvider.of<OperatorsBloc>(context).add(ApplyOperatorFilterDate(_dateFilter));
//    }
//  }
//}
//
//class ChildItem extends StatelessWidget {
//  final Account operator;
//
//  ChildItem(this.operator);
//
//  @override
//  Widget build(BuildContext context) {
//    //TOMAYBEDO add icons by account's properties
//    return GestureDetector(
//      onTap: () => BlocProvider.of<BackdropBloc>(context).add(
//          NavigateEvent(global.Constants.dailyCalendarRoute, [operator, null])),
//      child: Container(
//        height: 50,
//        padding: EdgeInsets.symmetric(horizontal: 20),
//        child: Row(
//          children: <Widget>[
//            Container(
//              margin: EdgeInsets.only(right: 10.0),
//              padding: EdgeInsets.all(3.0),
//              child: Icon(
//                Icons.work,
//                color: yellow,
//              ),
//              decoration: BoxDecoration(
//                borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                color: black,
//              ),
//            ),
//            Text(operator.surname.toUpperCase() + " ", style: title),
//            Text(operator.name, style: subtitle),
//
//          ],
//        ),
//      ),
//    );
//  }
//}
