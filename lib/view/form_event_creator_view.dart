import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import '../models/event.dart';


class EventCreator extends StatefulWidget {
  Event _event;

  @override
  State<StatefulWidget> createState() {
    return new EventCreatorState();
  }

  EventCreator(this._event) {
    if(this._event == null)_event=new Event.empty();
    createState();
  }
}

class EventCreatorState extends State<EventCreator> {
  final dateFormat = DateFormat("EEE d MMM y");
  final timeFormat = DateFormat("HH:mm");
  final _formKey = GlobalKey<FormState>();
  bool _allDayFlag = false;
  int _radioValue = 0;
  List<String> _categoriesN = List();
  List<dynamic> _categoriesC = List();

  @override
  void initState() {
    getCategories();
  }

  @override
  Widget build(BuildContext context) {

    double iconspace = 30.0;//handle

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
      body: new Form(
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
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child:Row(
                        children: <Widget>[
                          Container(
                            width: iconspace,
                            margin: EdgeInsets.only(right: 20.0),
                            child: Icon(FontAwesomeIcons.clock, color: dark, size: iconspace,),
                          ),
                          Expanded(
                            child: Text("Tutto il giorno", style: label),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: Switch(value: _allDayFlag, activeColor: dark, onChanged: (v){
                              setState(() {
                                _allDayFlag = v;
                              });
                            }),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: iconspace,
                          margin: EdgeInsets.only(right: 20.0),
                        ),
                        Expanded(
                          child: new DateTimePickerFormField(
                            textAlign: TextAlign.left,
                            initialDate: widget._event.start,
                            initialValue: widget._event.start,
                            inputType: InputType.date,
                            format: dateFormat,
                            keyboardType: TextInputType.number,
                            style: label,
                            decoration: InputDecoration(
                              hintText: 'Mon 1 Sep 2019',
                              hintStyle: label,
                              border: InputBorder.none
                            ),
                            resetIcon: null,
                            autovalidate: false,
                            editable: false,
                            validator: (val){
                              if ( (val != null) && (val.year >= 2015 && val.year <= 3000)) {
                                widget._event.start = val;
                                return null;
                              } else {
                                return 'Please enter a valid date';
                              }
                            },
                            onSaved: (DateTime value) => widget._event.start = value,
                          ),
                        ),
                        Expanded(
                          child:
                          new DateTimePickerFormField(
                            textAlign: TextAlign.right,
                            initialDate: widget._event.start,
                            inputType: InputType.time,
                            format: timeFormat,
                            keyboardType: TextInputType.number,
                            style: label,
                            decoration: InputDecoration(
                                hintText: '10:00',
                                hintStyle: label,
                                border: InputBorder.none
                            ),
                            resetIcon: null,
                            autovalidate: false,
                            editable: false,
                            validator: (val){
                              if (val != null){
                                widget._event.start = widget._event.start.add(Duration(milliseconds: val.millisecondsSinceEpoch));
                                return null;
                              } else {
                                return 'Please enter a valid hour';
                              }
                            },
                            onSaved: (DateTime value) => widget._event.start = widget._event.start.add(Duration(milliseconds: value.millisecondsSinceEpoch)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: iconspace,
                          margin: EdgeInsets.only(right: 20.0),
                        ),
                        Expanded(
                          child: new DateTimePickerFormField(
                            textAlign: TextAlign.left,
                            initialDate: widget._event.end,
                            initialValue: widget._event.end,
                            inputType: InputType.date,
                            format: dateFormat,
                            keyboardType: TextInputType.number,
                            style: label,
                            decoration: InputDecoration(
                                hintText: 'Mon 1 Sep 2019',
                                hintStyle: label,
                                border: InputBorder.none
                            ),
                            resetIcon: null,
                            autovalidate: false,
                            editable: false,
                            enabled: !_allDayFlag,
                            validator: (val){
                              if(_allDayFlag)return null;
                              if ((val != null) && (val.year >= 2015 && val.year <= 3000) && widget._event.start.millisecondsSinceEpoch<=val.add(Duration(days: 1)).millisecondsSinceEpoch) {
                                widget._event.end = val;
                                return null;
                              } else {
                                return 'Please enter a valid date';
                              }
                            },
                            onSaved: (DateTime value) => widget._event.end = value,
                          ),
                        ),
                        Expanded(
                          child:
                          new DateTimePickerFormField(
                            textAlign: TextAlign.right,
                            initialDate: widget._event.end,
                            inputType: InputType.time,
                            format: timeFormat,
                            keyboardType: TextInputType.number,
                            style: label,
                            decoration: InputDecoration(
                                hintText: '10:00',
                                hintStyle: label,
                                border: InputBorder.none
                            ),
                            resetIcon: null,
                            autovalidate: false,
                            editable: false,
                            enabled: !_allDayFlag,
                            validator: (val){
                              if(_allDayFlag)return null;
                              if (val != null && widget._event.start.millisecondsSinceEpoch <= widget._event.end.add(Duration(milliseconds: val.millisecondsSinceEpoch)).millisecondsSinceEpoch){
                                widget._event.end = widget._event.end.add(Duration(milliseconds: val.millisecondsSinceEpoch));
                                return null;
                              } else {
                                return 'Please enter a valid hour';
                              }
                            },
                            onSaved: (DateTime value) => widget._event.end = widget._event.end.add(Duration(milliseconds: value.millisecondsSinceEpoch)),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light),
                    Row(children: <Widget>[
                      Container(
                        width: iconspace,
                        margin: EdgeInsets.only(right: 20.0),
                        child: Icon(FontAwesomeIcons.hardHat, color: dark, size: iconspace,),
                      ),
                      Expanded(
                          child: Text("Aggiungi operatore", style: label)
                      ),
                      IconButton(
                        onPressed: (){},
                        alignment: Alignment.centerRight,
                        icon: Icon(FontAwesomeIcons.plus, color: dark),
                      )
                    ]),
                    Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light),
                    Row(children: <Widget>[
                      Container(
                        width: iconspace,
                        margin: EdgeInsets.only(right: 20.0),
                        child: Icon(FontAwesomeIcons.map, color: dark, size: iconspace,),
                      ),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Aggiungi posizione',
                            hintStyle: subtitle,
                            border: InputBorder.none,
                          ),
                          initialValue: widget._event.title,
                          validator: (value)=>null,
                          onSaved: (String value) => widget._event.address = value,
                        ),
                      ),
                    ]),
                    Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light),Expanded(
                      child:Row(
                        children: <Widget>[
                          Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(top: 5.0, right: 20.0),
                              child: Text("Tipologia", style: title)
                          ),
                          Expanded(
                              child:
                              ListView.builder(
                                itemCount: _categoriesN.length,
                                itemBuilder: (context, index) {
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
                                },))
                        ],
                      )
                      ,),
                  ])
          )

      ),
    );
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
    });
  }

  getCategories(){
    PlatformUtils.fireDocument("Costanti","Categorie").then((doc){
      if(doc.exists && doc != null){
        setState(() {
          _categoriesN = doc.data().keys.toList();
          _categoriesC = doc.data().values.toList();
        });
      }
    });
  }


  Future _saveNewEvent(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      print("Firebase save");
      widget._event.category = _categoriesN[_radioValue];
      widget._event.color = _categoriesC[_radioValue];
      if(_allDayFlag)widget._event.end = widget._event.start;
      PlatformUtils.fire.collection("Eventi").add(widget._event.toDocument());
      Utils.notify();
      Navigator.maybePop(context);
    }
  }

}