import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/view/operator_selection_view.dart';
import 'package:venturiautospurghi/models/event.dart';


class EventCreator extends StatefulWidget {
  Event _event;

  @override
  State<StatefulWidget> createState() {
    return new EventCreatorState();
  }

  EventCreator(this._event) {
    if(this._event == null){
      _event=new Event.empty();
      _event.start = Utils.formatDate(_event.start, "day").add(Duration(hours:6));
      _event.end =_event.start.add(Duration(minutes:30));
    }
  }
}

class EventCreatorState extends State<EventCreator> {
  final dateFormat = DateFormat("EEE d MMM y");
  final timeFormat = DateFormat("HH:mm");
  final _formKey = GlobalKey<FormState>();
  final _formDateKey = GlobalKey<FormState>();
  bool _allDayFlag = false;
  int _radioValue = 0;
  List<String> _categoriesN = List();
  List<dynamic> _categoriesC = List();
  DateTime now = DateTime.now().add(Duration(hours:2));
  Color colorValidator = dark;
  bool enabledField = false;
  Account _supervisor;


  @override
  void initState() {
    super.initState();
    _supervisor = BlocProvider.of<AuthenticationBloc>(context).account;
    enabledField = widget._event.id!=null&&widget._event.id!=""?!widget._event.start.isBefore(now.subtract(Duration(minutes:5))):true;
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    double iconspace = 30.0;//handle

    List<Widget> listCat = _categoriesN.map((n){
      int index = _categoriesN.indexOf(n);
      return Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
              color: (_radioValue==index)?dark:white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: dark)
          ),
          child: Row(
              children: <Widget>[
                new Radio(
                  value: index,
                  activeColor: almost_dark,
                  groupValue: _radioValue,
                  onChanged: _handleRadioValueChange,
                ),
                Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: HexColor(_categoriesC[index])
                  ),
                ),
                new Text(_categoriesN[index], style: (_radioValue==index)?subtitle_rev:subtitle.copyWith(color: dark)),
              ]
          )
      );
    }).toList();

    List<Widget> listOp = (widget._event.operator!=null?[widget._event.operator, ...widget._event.suboperators]:widget._event.suboperators).map((op){
      Account entity = Account.fromMap("",op);
      return Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10.0),
              padding: EdgeInsets.all(2.0),
              child: Icon(Icons.work, color: yellow,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: dark,
              ),
            ),
            Text(entity.surname.toUpperCase()+" ", style: title),
            Text(entity.name, style: subtitle),
            Expanded(child: Container(),),
            op!=widget._event.operator&&enabledField?IconButton(
              icon: Icon(Icons.close, color: dark),
              onPressed: (){
                widget._event.suboperators.remove(op);
                setState((){});
              }):Container()
          ],
        ),
      );
    }).toList();

    return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(),
        title: new Text('Create New Event'),
        actions: <Widget>[
          new Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(15.0),
            child: new InkWell(
              child: new Text(
                'SAVE',
                style: TextStyle(
                    fontSize: 20.0),
              ),
              onTap: () => _saveNewEvent(context),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: new Form(
            key: this._formKey,
            child: new Container(
                padding: EdgeInsets.all(10.0),
                child: new Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Titolo',
                            hintStyle: subtitle,
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.0,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          initialValue: widget._event.title,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Il campo \'Titolo\' è obbligatorio';
                            }
                            return null;
                          },
                          onSaved: (String value) => widget._event.title = value,
                        ),
                      ),
                      Divider(height: 40, indent: 20, endIndent: 20, thickness: 2, color: grey_light),
                      Row(children: <Widget>[
                        Container(
                          width: iconspace,
                          margin: EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.note, color: dark, size: iconspace,),
                        ),
                        Expanded(
                          child: TextFormField(
                            maxLines: 3,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Aggiungi note',
                              hintStyle: subtitle,
                              border: InputBorder.none,
                            ),
                            initialValue: widget._event.description,
                            validator: (value)=>null,
                            onSaved: (String value) => widget._event.description = value,
                          ),
                        ),
                      ]),
                      Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light),
                      Row(children: <Widget>[
                        Container(
                          width: iconspace,
                          margin: EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.map, color: dark, size: iconspace,),
                        ),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Aggiungi posizione',
                              hintStyle: subtitle,
                              border: InputBorder.none,
                            ),
                            initialValue: widget._event.address,
                            validator: (value)=>null,
                            onSaved: (String value) => widget._event.address = value,
                          ),
                        ),
                      ]),
                      Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child:Row(
                          children: <Widget>[
                            Container(
                              width: iconspace,
                              margin: EdgeInsets.only(right: 20.0),
                              child: Icon(Icons.access_time, color: dark, size: iconspace,),
                            ),
                            Expanded(
                              child: Text(enabledField?"Tutto il giorno":"Orario", style: label),
                            ),
                            enabledField?Container(
                              alignment: Alignment.centerRight,
                              child: Switch(value: _allDayFlag, activeColor: dark, onChanged: (v){
                                setState(() {
                                  if(enabledField) _allDayFlag = v;
                                });
                              }),
                            ):Container()
                          ],
                        ),
                      ),
                      Form(
                        key: _formDateKey,
                        child: Column(children: <Widget>[
                          Row(
                              children: <Widget>[
                                Container(
                                  width: iconspace,
                                  margin: EdgeInsets.only(right: 20.0),
                                ),
                                Expanded(
                                  child: DateTimeField(
                                    decoration: InputDecoration(
                                        hintText: 'Mon 1 Sep 2019',
                                        hintStyle: label,
                                        border: InputBorder.none
                                    ),
                                    style: label,
                                    format: dateFormat,
                                    initialValue: widget._event.start,
                                    readOnly: true,
                                    enabled: enabledField,
                                    resetIcon: null,
                                    onShowPicker: (context, currentValue) {
                                      return showDatePicker(
                                          context: context,
                                          firstDate: Utils.formatDate(now, "day"),
                                          initialDate: currentValue!=null?currentValue.year>2000?currentValue:
                                          DateTime(2000+currentValue.year, currentValue.month, currentValue.day, currentValue.hour, currentValue.minute)
                                              :Utils.formatDate(now, "day"),
                                          lastDate: DateTime(3000)
                                      );
                                    },
                                    onChanged: (newValue)=>resetOperatorsFields(),
                                    validator: (val){
                                      if (val != null){
                                        widget._event.start = Utils.formatDate(val, "day");
                                        return null;
                                      } else {
                                        return 'Inserisci una data valida';
                                      }
                                    },
                                    onSaved: (DateTime value) => widget._event.start = Utils.formatDate(value, "day"),
                                  ),
                                ),
                                Expanded(
                                  child:
                                  new DateTimeField(
                                      decoration: InputDecoration(
                                          hintText: '10:00',
                                          hintStyle: label,
                                          border: InputBorder.none
                                      ),
                                      textAlign: TextAlign.right,
                                      style: label,
                                      format: timeFormat,
                                      initialValue: widget._event.start,
                                      enabled: !_allDayFlag&&enabledField,
                                      readOnly: true,
                                      resetIcon: null,
                                      onShowPicker: (context, currentValue) async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime(0)),
                                        );
                                        return DateTimeField.convert(time);
                                      },
                                      onChanged: (newValue)=>resetOperatorsFields(),
                                      validator: (val){
                                        if(_allDayFlag)return null;
                                        if (val != null && (val.hour>=6) && (Utils.formatDate(widget._event.start,"day")==Utils.formatDate(now,"day")?
                                          val.hour>now.hour || (val.hour==now.hour && val.minute>now.minute):true)){
                                          widget._event.start = Utils.formatDate(widget._event.start,"day").add(Duration(hours: val.hour,minutes: val.minute));
                                          return null;
                                        } else {
                                          return 'Inserisci un orario valido';
                                        }
                                      },
                                      onSaved: (DateTime value) => widget._event.start = value != null ? Utils.formatDate(widget._event.start,"day").add(Duration(hours: value.hour,minutes: value.minute)): widget._event.start),
                                ),
                              ]),
                          Row(
                            children: <Widget>[
                              Container(
                                width: iconspace,
                                margin: EdgeInsets.only(right: 20.0),
                              ),
                              Expanded(
                                child: DateTimeField(
                                  decoration: InputDecoration(
                                      hintText: 'Mon 1 Sep 2019',
                                      hintStyle: label,
                                      border: InputBorder.none
                                  ),
                                  style: label,
                                  format: dateFormat,
                                  initialValue: widget._event.end,
                                  enabled: !_allDayFlag&&enabledField,
                                  readOnly: true,
                                  resetIcon: null,
                                  onShowPicker: (context, currentValue) {
                                    return showDatePicker(
                                        context: context,
                                        firstDate: Utils.formatDate(now, "day"),
                                        initialDate: currentValue!=null?currentValue.year>2000?currentValue:
                                        DateTime(2000+currentValue.year, currentValue.month, currentValue.day, currentValue.hour, currentValue.minute)
                                            :Utils.formatDate(now, "day"),
                                        lastDate: DateTime(3000)
                                    );
                                  },
                                  onChanged: (newValue)=>resetOperatorsFields(),
                                  validator: (val){
                                    if(_allDayFlag)return null;
                                    if ((val != null) && (val.year >= 2015 && val.year <= 3000) && widget._event.start.isBefore(val.add(Duration(days: 1)))) {
                                      widget._event.end = Utils.formatDate(val, "day");
                                      return null;
                                    } else {
                                      return 'Inserisci una data valida';
                                    }
                                  },
                                  onSaved: (DateTime value) => widget._event.end = Utils.formatDate(value, "day"),
                                ),
                              ),
                              Expanded(
                                child:
                                new DateTimeField(
                                    decoration: InputDecoration(
                                        hintText: '10:00',
                                        hintStyle: label,
                                        border: InputBorder.none
                                    ),
                                    textAlign: TextAlign.right,
                                    style: label,
                                    format: timeFormat,
                                    initialValue: widget._event.end,
                                    enabled: !_allDayFlag&&enabledField,
                                    readOnly: true,
                                    resetIcon: null,
                                    onShowPicker: (context, currentValue) async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime(0)),
                                      );
                                      return DateTimeField.convert(time);
                                    },
                                    onChanged: (newValue)=>resetOperatorsFields(),
                                    validator: (val){
                                      if(_allDayFlag)return null;
                                      if(val != null && (widget._event.start.isBefore(widget._event.end.add(Duration(hours: val.hour, minutes: val.minute-29))))
                                          && (val.hour<21 || (val.hour==21 && val.minute==0))) {
                                        return null;
                                      } else {
                                        return 'Inserisci un orario valido';
                                      }
                                    },
                                    onSaved: (DateTime value) => widget._event.end = value!=null?widget._event.end.add(Duration(hours: value.hour, minutes: value.minute)):widget._event.end
                                ),
                              )
                            ],
                          ),
                        ],),
                      ),
                      Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light),
                      Row(children: <Widget>[
                        Container(
                          width: iconspace,
                          margin: EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.work, color: dark, size: iconspace,),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(enabledField?"Aggiungi operatore":"Operatori", style: label.copyWith(color: colorValidator))
                          ),
                        ),
                        enabledField?IconButton(
                          icon: Icon(Icons.add, color: colorValidator),
                          onPressed: enabledField?() async {
                            if(!_formDateKey.currentState.validate()) return Fluttertoast.showToast(
                                msg: "Inserisci un intervallo temporale valido",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                            var result = await PlatformUtils.navigator(context, new OperatorSelection(widget._event, true));
                            widget._event = result;
                            setState((){});
                          }:null,
                        ):Container()
                      ]),
                      Container(
                          child: Column(
                              children: listOp
                          )
                      ),
                      Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light),
                      Container(
                        child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(top: 5.0, right: 20.0),
                                child: Text("Tipologia", style: title)
                            ),
                            Expanded(
                              child: Column(
                                children: listCat
                              )
                            )
                          ],
                        ),
                      ),
                      Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light),
                    ])
            )
        ),
      ),
    );


  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
    });
  }

  getCategories() async {
    PlatformUtils.fireDocument("Costanti","Categorie").get().then((doc){
      if(doc.exists && doc != null){
        dynamic data = PlatformUtils.extractFieldFromDocument(null,doc);
        setState(() {
          _categoriesN = data.keys.toList();
          _categoriesC = data.values.toList();
        });
      }
    });
  }

  resetOperatorsFields(){
    setState(() {
      widget._event.idOperator = "";
      widget._event.idOperators = [];
      widget._event.operator = null;
      widget._event.suboperators = [];
    });
  }

  //TODO
  Future _saveNewEvent(BuildContext context) async {
    if (widget._event.operator==null) setState((){colorValidator = red;}); else setState((){colorValidator = dark;});
    if ((this._formDateKey.currentState.validate()||!enabledField) && this._formKey.currentState.validate() && widget._event.operator!=null) {
      _formDateKey.currentState.save();
      _formKey.currentState.save();
      print( widget._event.start);
      print( widget._event.end);
      print("Firebase save");
      widget._event.idSupervisor = _supervisor.id;
      widget._event.supervisor = _supervisor.toDocument();
      widget._event.category = _categoriesN[_radioValue];
      widget._event.color = _categoriesC[_radioValue];
      widget._event.status = Status.New;
      if(_allDayFlag) {
        widget._event.start = Utils.formatDate(widget._event.start,"day").add(Duration(hours: 6));
        widget._event.end = Utils.formatDate(widget._event.start,"day").add(Duration(hours: 21));
      }
      dynamic docRef;
      try{
        if(widget._event.id!="" && widget._event.id!=null){
          PlatformUtils.fire.collection(global.Constants.tabellaEventi).document(widget._event.id).updateData(widget._event.toDocument());
          docRef = widget._event.id;
        }else{
          docRef = await PlatformUtils.fire.collection(global.Constants.tabellaEventi).add(widget._event.toDocument());
          docRef = PlatformUtils.extractFieldFromDocument("id", docRef);
        }
        Utils.notify(token: widget._event.operator["Token"], evento: docRef);
        Navigator.pop(context);
      }catch(e){print(e);}
    }
  }

}