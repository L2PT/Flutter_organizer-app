import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/models/user.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repository/events_repository.dart';
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
  final dateFormat = DateFormat("EEE d MMM y",'it_IT');
  final timeFormat = DateFormat("HH:mm",'it_IT');
  final _formKey = GlobalKey<FormState>();
  final _formDateKey = GlobalKey<FormState>();
  bool _allDayFlag = false;
  int _radioValue = -1;
  List<String> _categoriesN = List();
  List<dynamic> _categoriesC = List();
  DateTime now = DateTime.now();
  Color colorValidator = dark;
  bool enabledField = false;
  Account _supervisor;
  String _title = '';
  List<String> _placesList;
  String _fileName;
  String _path;
  Map<String, String> _paths;
  bool _loadingPath = false;
  bool _multiPick = false;

  @override
  void initState() {
    super.initState();
    _supervisor = BlocProvider.of<AuthenticationBloc>(context).account;
    enabledField = widget._event.id!=null&&widget._event.id!=""?!widget._event.start.isBefore(now.subtract(Duration(minutes:4))):true;
    if(widget._event.documents!=null && widget._event.documents!=""){
      if(widget._event.documents.split("/").length>0)
        _paths=new Map.fromIterable(widget._event.documents.split("/"), key: (v) => v, value: (v) => "from cloud");
      else
        _path=widget._event.documents;
    }
    getCategories();
    setState(() {
      _title =widget._event.operator==null?'NUOVO EVENTO':'MODIFICA EVENTO';
    });
  }

  @override
  Widget build(BuildContext context) {
    double iconspace = 30.0;//handle
    List<Widget> listCat = _categoriesN.map((n){
      int index = _categoriesN.indexOf(n);
      if(_radioValue == -1){
        _radioValue = 0;
      }
      return GestureDetector(
          onTap: ()=>_handleRadioValueChange(index),
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                  color: (_radioValue==index)?dark:white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: grey)
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
                    new Text(_categoriesN[index].toUpperCase(), style: (_radioValue==index)?subtitle_rev:subtitle.copyWith(color: dark)),
                  ]
              )
          )
      );
    }).toList();

    List<Widget> listOp = (widget._event.operator!=null?[widget._event.operator, ...widget._event.suboperators]:widget._event.suboperators).map((op){
      Account entity = Account.fromMap("",op);
      return Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 15),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10.0),
              padding: EdgeInsets.all(3.0),
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
                icon: Icon(Icons.delete, color: dark, size: 25,),
                onPressed: (){
                  List<String> tempRemovingList = new List.from(widget._event.idOperators);
                  tempRemovingList.remove(widget._event.idOperator);
                  tempRemovingList.removeAt(widget._event.suboperators.indexOf(op));
                  widget._event.idOperators = tempRemovingList;
                  List<dynamic> temp2RemovingList = new List.from(widget._event.suboperators);
                  temp2RemovingList.remove(op);
                  widget._event.suboperators = temp2RemovingList;
                  setState((){});
                }):Container()
          ],
        ),
      );
    }).toList();

    return WillPopScope(
        onWillPop: (){_onBackPressed();},
        child: new Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,

          appBar: new AppBar(
            leading: new BackButton(
              onPressed: _onBackPressed,
            ),
            title: new Text(_title,style: title_rev,),
            actions: <Widget>[
              new Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(15.0),
                  child:
                  RaisedButton(
                    child: new Text('SALVA', style: subtitle_rev),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        side: BorderSide(color: white)
                    ),
                    elevation: 5,
                    onPressed: () => _saveNewEvent(context),
                  )
              )
            ],
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: new Form(
                key: this._formKey,
                child: new Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        margin: EdgeInsets.only(top: 10),
                        child: TextFormField(
                          cursorColor: dark,
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
                          child: Icon(Icons.assignment, color: dark, size: iconspace,),
                        ),
                        Expanded(
                          child: TextFormField(
                            maxLines: 3,
                            cursorColor: dark,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                hintText: 'Aggiungi note',
                                hintStyle: subtitle,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: dark, width: 1.0))
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
                            child:
                            TextFormField(
                              onChanged: (text) {
                                getLocationsResult(text);
                              },
                              keyboardType: TextInputType.text,
                              cursorColor: dark,
                              decoration: InputDecoration(
                                hintText: 'Aggiungi posizione',
                                hintStyle: subtitle,
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2.0,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                              initialValue: widget._event.address,
                              validator: (value) => null,
                              onSaved: (String value) =>
                              widget._event.address = value,
                            )
                        ),
                      ]),
                      Row(
                         children: <Widget>[
                          Expanded(
                          child: Column(
                            children:
                              buildAutocompleteMaps()

                          ))
                             ],
                      ),
                      Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light),
                      Row(children: <Widget>[
                        Container(
                          width: iconspace,
                          margin: EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.file_upload, color: dark, size: iconspace,),
                        ),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            cursorColor: dark,
                            readOnly: true,
                            onTap: () => _openFileExplorer(),
                            decoration: InputDecoration(
                              hintText: 'Aggiungi documento',
                              hintStyle: subtitle,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.0,
                                  style: BorderStyle.none,
                                ),
                              ),
                            ),
                            validator: (value)=>null,
                            onSaved: (String value) => widget._event.address = value,
                          ),
                        ),
                      ]),
                      _loadingPath?
                      Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: const CircularProgressIndicator()
                      )
                          : _path != null || _paths != null ?
                      new Container(
                        height: 60,
                        child: new Scrollbar(
                            child: new ListView.separated(
                              itemCount: _paths != null && _paths.isNotEmpty? _paths.length: 1,
                              itemBuilder: (BuildContext context, int index) {
                                final bool isMultiPath = _paths != null && _paths.isNotEmpty;
                                final String name = (isMultiPath? 'File: ' +_paths.keys.toList()[index]:'File ${index+1}: '+ _fileName ?? '...');
                                final path = isMultiPath? _paths.values.toList()[index].toString(): _path;
                                return new ListTile(
                                  title: new Text(name),
                                  subtitle: new Text(path),
                                  trailing: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: (){
                                      if(_path!=null){
                                        _path=null;
                                      }else{
                                        _paths.remove(_paths.keys.toList()[index]);
                                        if(_paths.keys.toList().length==0)_paths=null;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) => new Divider(),
                            )),
                      )
                          : new Container(),
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
                                _allDayFlag?Container():
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
                                      enabled: enabledField,
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
                                        if (val != null && (val.hour>=global.Constants.MIN_WORKHOUR_SPAN) && (Utils.formatDate(widget._event.start,"day")==Utils.formatDate(now,"day")?
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
                          _allDayFlag?Container():
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
                                  enabled: enabledField,
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
                                      if(val != null && (widget._event.start.isBefore(widget._event.end.add(Duration(hours: val.hour, minutes: (val.minute+1)-global.Constants.WORKHOUR_SPAN))))
                                          && (val.hour<global.Constants.MAX_WORKHOUR_SPAN || (val.hour==global.Constants.MAX_WORKHOUR_SPAN && val.minute==0))) {
                                        widget._event.end = val!=null?Utils.formatDate(widget._event.end,"day").add(Duration(hours: val.hour, minutes: val.minute)):widget._event.end;
                                      } else {
                                        return 'Inserisci un orario valido';
                                      }
                                      return null;
                                    },
                                    onSaved: (DateTime value) => widget._event.end = value!=null?Utils.formatDate(widget._event.end,"day").add(Duration(hours: value.hour, minutes: value.minute)):widget._event.end
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
                            if(!_formDateKey.currentState.validate()) return PlatformUtils.onErrorMessage("Inserisci un intervallo temporale valido");
                            Event tempEvent = widget._event;
                            if(_allDayFlag) {
                              tempEvent.start = Utils.formatDate(widget._event.start,"day").add(Duration(hours: global.Constants.MIN_WORKHOUR_SPAN));
                              tempEvent.end = Utils.formatDate(widget._event.start,"day").add(Duration(hours: global.Constants.MAX_WORKHOUR_SPAN));
                            }
                            var result = await PlatformUtils.navigator(context, new OperatorSelection(tempEvent, true));
                            if(!(result is bool)){
                              widget._event = result;
                              setState((){});
                            }
                            return null;
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
            ),
          ),
        )
    );

  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      if (_multiPick) {
        _path = null;
        _paths = await PlatformUtils.multiFilePicker();
      } else {
        _paths = null;
        _path = await PlatformUtils.filePicker();
      }
    } on Exception catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName = _path != null
          ? _path.split('/').last
          : _paths != null ? _paths.keys.toString() : '...';
    });
  }

  void _onBackPressed(){
    if(Navigator.canPop(context)){
      Navigator.pop(context);
    }else{
      Utils.NavigateTo(context, global.Constants.homeRoute, null);
    }
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
          _radioValue = _categoriesN.indexOf(widget._event.category);
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

  Future _saveNewEvent(BuildContext context) async {
    if (widget._event.operator==null) setState((){colorValidator = red;}); else setState((){colorValidator = dark;});
    if ((this._formDateKey.currentState.validate()||!enabledField) && this._formKey.currentState.validate() && widget._event.operator!=null) {
      _formDateKey.currentState.save();
      _formKey.currentState.save();
      print("Firebase save "+widget._event.start.toString()+" : "+widget._event.end.toString());
      widget._event.idSupervisor = _supervisor.id;
      widget._event.supervisor = _supervisor.toDocument();
      widget._event.category = _categoriesN[_radioValue];
      widget._event.color = _categoriesC[_radioValue];
      widget._event.status = Status.New;
      var oldDocumentsList = widget._event.documents.split("/");
      widget._event.documents = _path!=null?_path.split("/").last:_paths!=null?_paths.keys.join("/"):"";
      if(_allDayFlag) {
        widget._event.start = Utils.formatDate(widget._event.start,"day").add(Duration(hours: global.Constants.MIN_WORKHOUR_SPAN));
        widget._event.end = Utils.formatDate(widget._event.start,"day").add(Duration(hours: global.Constants.MAX_WORKHOUR_SPAN));
      }
      dynamic docRef;
      try{
        if(widget._event.id!="" && widget._event.id!=null){
          EventsRepository().updateEvent(widget._event, null, widget._event.toDocument());
          docRef = widget._event.id;
        }else{
          docRef = await EventsRepository().addEvent(widget._event, widget._event.toDocument());
          docRef = PlatformUtils.extractFieldFromDocument("id", docRef);
        }
        if(_path!=null) _paths = Map.of({_path.split('/').last: _path});
        _paths?.forEach((singleName,singlePath){
          oldDocumentsList.remove(singleName);
          if(singlePath.contains("/")) PlatformUtils.storage.ref().child(widget._event.id+"/"+singleName).putFile(PlatformUtils.file(singlePath));
        });
        oldDocumentsList?.forEach((fileNameToDelate){
          PlatformUtils.storage.ref().child(widget._event.id+"/"+fileNameToDelate).delete();
        });
        Utils.notify(token: widget._event.operator["Token"], eventId: docRef);
        Navigator.pop(context);
      }catch(e){print(e);}
    }
  }


  void getLocationsResult(String text) async{
    if(text.isNotEmpty){
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String language = 'it';
      String type= 'address';
      String key = global.Constants.googleMapsApiKey;
      String request = '$baseURL?input=$text&key=$key&type=$type&language=$language';

      Response response = await Dio().get(request);

      final predictions = response.data['predictions'];

      List<String> _displayResults = [];
      for (var i=0; i < 3; i++) {
        String name = predictions[i]['description'];
        _displayResults.add(name);
      }
      setState(() {
        this._placesList = _displayResults;
      });
    }
  }

  List<Widget> buildAutocompleteMaps() {
    List<Widget> listPlace =_placesList.map((place) {
      return Container(
        child: Text(place),
      );
    }).toList();
    return listPlace;
  }
}