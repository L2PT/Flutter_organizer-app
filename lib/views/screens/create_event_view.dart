import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/cubit/create_event/create_event_cubit.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/colors.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';

class CreateEvent extends StatelessWidget {
  final Event _event;
  static const iconWidth = 30.0; //HANDLE

  CreateEvent([this._event]);

  @override
  Widget build(BuildContext context) {
    var repository = RepositoryProvider.of<CloudFirestoreService>(context);
    var account = BlocProvider.of<AuthenticationBloc>(context).account;

    return new BlocProvider(
        create: (_) => CreateEventCubit(repository, account, _event),
        child: WillPopScope(
            onWillPop: (){ PlatformUtils.backNavigator(context); },
            child: new Scaffold(
                extendBody: true,
                resizeToAvoidBottomInset: false,
                appBar: new AppBar(
                  leading: new BackButton(
                    onPressed: () => PlatformUtils.backNavigator(context)
                  ),
                  title: new Text(
                    _event == null ? 'NUOVO EVENTO' : 'MODIFICA EVENTO',
                    style: title_rev,
                  ),
                  actions: <Widget>[ _viewHeader()
                  ],
                ),
                body: BlocBuilder<CreateEventCubit, CreateEventState>(
                    buildWhen: (previous, current) => previous.status != current.status,
                    builder: (context, state) {
                      return context.bloc<CreateEventCubit>().state.isLoading() ?
                      LoadingScreen() : _formInputList();   //TODO maybe a success animation can be added
                    })
        ))
    );
  }
}

class _viewHeader extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    void _onSavePressed(BuildContext context) async {
      if (await context.bloc<CreateEventCubit>().saveEvent())
        Navigator.pop(context);
    }

    return new Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(15.0),
      child: RaisedButton(
        child: new Text('SALVA', style: subtitle_rev),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)), side: BorderSide(color: white)),
        elevation: 5,
        onPressed: ()=>_onSavePressed(context),
      ));
  }
}

class _formInputList extends StatelessWidget{
  double iconWidth = CreateEvent.iconWidth;

  @override
  Widget build(BuildContext context) {
    Event event = context.bloc<CreateEventCubit>().state.event;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: new Form(
          key: context.bloc<CreateEventCubit>().formKey,
          child: new Column(children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              margin: EdgeInsets.only(top: 10),
              child: TextFormField(
                cursorColor: black,
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
                initialValue: event.title,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Il campo \'Titolo\' è obbligatorio';
                  }
                  return null;
                },
                onSaved: (String value) => event.title = value,
              ),
            ),
            Divider(height: 40, indent: 20, endIndent: 20, thickness: 2, color: grey_light2),
            Row(children: <Widget>[
              Container(
                width: iconWidth,
                margin: EdgeInsets.only(right: 20.0),
                child: Icon(Icons.assignment, color: black, size: iconWidth),
              ),
              Expanded(
                child: TextFormField(
                  maxLines: 3,
                  cursorColor: black,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      hintText: 'Aggiungi note',
                      hintStyle: subtitle,
                      border: OutlineInputBorder(borderSide: BorderSide(color: black, width: 1.0))),
                  initialValue: event.description,
                  validator: (value) => null,
                  onSaved: (String value) => event.description = value,
                ),
              ),
            ]),
            Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light2),
            Row(children: <Widget>[
              Container(
                width: iconWidth,
                margin: EdgeInsets.only(right: 20.0),
                child: Icon(
                  Icons.map,
                  color: black,
                  size: iconWidth,
                ),
              ),
              Expanded(
                  child: TextFormField(
                    onChanged: (text) => context.bloc<CreateEventCubit>().getLocations(text),
                    keyboardType: TextInputType.text,
                    cursorColor: black,
                    initialValue: event.address,
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
                  )),
            ]),
            _geoLocationOptionsList(),
            Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light2),
            Row(children: <Widget>[
              Container(
                width: iconWidth,
                margin: EdgeInsets.only(right: 20.0),
                child: Icon(
                  Icons.file_upload,
                  color: black,
                  size: iconWidth,
                ),
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  cursorColor: black,
                  readOnly: true,
                  onTap: () => context.bloc<CreateEventCubit>().openFileExplorer(),
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
                ),
              ),
            ]),
            _fileStorageList(),
            Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light2),
            _timeControls(),
            Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light2),
            Row(children: <Widget>[
              Container(
                width: iconWidth,
                margin: EdgeInsets.only(right: 20.0),
                child: Icon(FontAwesomeIcons.hardHat, color: black, size: iconWidth),
              ),
              Expanded(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(context.bloc<CreateEventCubit>().canModify ? "Aggiungi operatore" : "Operatori",
                        style: label)),
              ),
              context.bloc<CreateEventCubit>().canModify ? IconButton(
                  icon: Icon(Icons.add, color: black),
                  onPressed: () => context.bloc<CreateEventCubit>().addOperatorDialog(context)
              ) : Container()
            ]),
            _operatorsList(),
            Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light2),
            _categoriesList(),
            Divider(height: 20, indent: 20, endIndent: 20, thickness: 2, color: grey_light2),
          ])),
    );

  }
}


class _geoLocationOptionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> buildAutocompleteList() =>
    context.bloc<CreateEventCubit>().state.locations.map((location) {
      return GestureDetector(
          onTap: () => context.bloc<CreateEventCubit>().setAddress(location),
          child: Container(
              margin: EdgeInsets.only(bottom: 10, top: 10, left: 45),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: Icon(
                      Icons.place,
                      color: grey_dark,
                      size: 25,
                    ),
                  ),
                  Expanded(child: Text(location, style: label.copyWith(fontWeight: FontWeight.bold),
                  ),
                  )
                ],
              )));
    }).toList();

    return BlocBuilder<CreateEventCubit, CreateEventState>(
      buildWhen: (previous, current) => previous.locations != current.locations,
      builder: (context, state) {
        return (context.bloc<CreateEventCubit>().state.locations) != List<String>.empty() ?
        Row(
          children: <Widget>[
            Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Column(
                    children: buildAutocompleteList(),
                  ),
                ))
          ],
        ) : Container();
      },
    );
  }

}

class _fileStorageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    ListView buildFilesList() => ListView.separated(
      separatorBuilder: (context, index) => new Divider(),
      physics: BouncingScrollPhysics(),
      itemCount: context.bloc<CreateEventCubit>().state.documents.keys.length,
      itemBuilder: (context, index) =>
          ListTile(
            title: new Text(context.bloc<CreateEventCubit>().state.documents.keys.elementAt(index)),
            subtitle: new Text(context.bloc<CreateEventCubit>().state.documents.values.elementAt(index) == null?"":"Nuovo"),
            trailing: IconButton(
              icon: Icon(Icons.close, color: black,),
              onPressed: () => context.bloc<CreateEventCubit>().removeDocument(context.bloc<CreateEventCubit>().state.documents.keys.elementAt(index)),
            ),
          )
    );

    return BlocBuilder<CreateEventCubit, CreateEventState>(
      buildWhen: (previous, current) => previous.documents != current.documents,
      builder: (context, state) {
        return new Container(
          height: 60,
          child: buildFilesList()
        );
      },
    );
  }
}

class _timeControls extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Event event = context.bloc<CreateEventCubit>().state.event;
    double iconWidth = CreateEvent.iconWidth;

    Widget dateTimeStartPicker() => Row(children: <Widget>[
      Container(
        width: iconWidth,
        margin: EdgeInsets.only(right: 20.0),
      ),
      Expanded(
        child: GestureDetector(
          child: Text( event.start.toString().split(' ').first,
            style: context.bloc<CreateEventCubit>().canModify ? title : subtitle),
          onTap: () => context.bloc<CreateEventCubit>().canModify ?
          DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime.now(),
            maxTime: DateTime(3000),
            theme: DatePickerAppTheme,
            currentTime: event.start,
            onConfirm: (date) => context.bloc<CreateEventCubit>().setStartDate(date),
          ) : null,
        ),
      ),
      context.bloc<CreateEventCubit>().state.isAllDay ? Container()
          : Expanded(
        child: GestureDetector(
          child: Text( event.start.toString().split(' ').last.split('.').first.substring(0,5),
            style: context.bloc<CreateEventCubit>().canModify ? title : subtitle),
          onTap: () => context.bloc<CreateEventCubit>().canModify ?
          DatePicker.showTimePicker(context,
            showTitleActions: true,
            theme: DatePickerAppTheme,
            currentTime: event.start,
            onConfirm: (time) => context.bloc<CreateEventCubit>().setStartTime(time),
          ) : null,
        ),
      ),
    ]);

    Widget dateTimeEndPicker() => context.bloc<CreateEventCubit>().state.isAllDay ? Container()
        : Row(
      children: <Widget>[
        Container(
          width: iconWidth,
          margin: EdgeInsets.only(right: 20.0),
        ),
        Expanded(
          child: GestureDetector(
            child: Text(event.end.toString().split(' ').first,
              style: context.bloc<CreateEventCubit>().canModify ? title : subtitle,),
            onTap: () =>
            context.bloc<CreateEventCubit>().canModify ?
            DatePicker.showDatePicker(context,
              showTitleActions: true,
              minTime: TimeUtils.truncateDate(event.start, "day"),
              maxTime: DateTime(3000),
              theme: DatePickerAppTheme,
              currentTime: event.end,
              locale: LocaleType.it,
              onConfirm: (date) => context.bloc<CreateEventCubit>().setEndDate(date),
            ) : null,
          ),
        ),
        Expanded(
          child: GestureDetector(
            child: Text(event.end.toString().split(' ').last.split('.').first.substring(0,5),
              style: context.bloc<CreateEventCubit>().canModify ? title : subtitle,
            ),
            onTap: (){if(context.bloc<CreateEventCubit>().canModify)
            DatePicker.showTimePicker(context,
              showTitleActions: true,
              theme: DatePickerAppTheme,
              currentTime: event.end,
              locale: LocaleType.it,
              onConfirm: (time) => context.bloc<CreateEventCubit>().setEndTime(time),
            );},
          ),
        )
      ],
    );

    Widget allDayFlag() => Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Container(
              width: iconWidth,
              margin: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.access_time, color: black, size: iconWidth),
            ),
            Expanded(
              child: Text(context
                  .bloc<CreateEventCubit>()
                  .canModify ? "Tutto il giorno" : "Orario", style: label),
            ),
            context.bloc<CreateEventCubit>().canModify ?
              Container(
                alignment: Alignment.centerRight,
                child: Switch(
                    value:context.bloc<CreateEventCubit>().state.isAllDay,
                    activeColor: black,
                    onChanged: context.bloc<CreateEventCubit>().setAlldayLong
                    )) : Container()
          ],));

    return new Form(
      key: context.bloc<CreateEventCubit>().formTimeControlsKey,
      child: BlocBuilder<CreateEventCubit, CreateEventState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          event = context.bloc<CreateEventCubit>().state.event;
          return Container(child:
          Column(children: <Widget>[
            allDayFlag(),
            dateTimeStartPicker(),
            dateTimeEndPicker(),
          ]));
        },
      )
    );
  }
}

class _operatorsList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<Widget> buildOperatorsList() => (context.bloc<CreateEventCubit>().state.event.operator != null
        ? [context.bloc<CreateEventCubit>().state.event.operator, ...context.bloc<CreateEventCubit>().state.event.suboperators]
        : context.bloc<CreateEventCubit>().state.event.suboperators).map((operator) {
      return Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 15),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10.0),
              padding: EdgeInsets.all(3.0),
              child: Icon(FontAwesomeIcons.hardHat, color: yellow),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: black,
              ),
            ),
            Text(operator.surname.toUpperCase() + " ", style: title),
            Text(operator.name, style: subtitle),
            Expanded(
              child: Container(),
            ),
            operator != context.bloc<CreateEventCubit>().state.event.operator && context.bloc<CreateEventCubit>().canModify ?
            IconButton(
              icon: Icon(Icons.delete, color: black, size: 25),
              onPressed: () => context.bloc<CreateEventCubit>().removeSuboperatorFromEventList(operator)
            ) : Container()
          ],
        ),
      );
    })?.toList();

    return BlocBuilder<CreateEventCubit, CreateEventState>(
      buildWhen: (previous, current) => previous.event.toString() != previous.event.toString(),
      builder: (context, state) {
        return Container(child: Column(children: buildOperatorsList()??[]));
      },
    );
  }
}

class _categoriesList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    int i = 0;
    int category = context.bloc<CreateEventCubit>().state.category;
    List<Widget> buildCategoriesList() => context.bloc<CreateEventCubit>().categories.map((categoryName, categoryColor) =>
        MapEntry( Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    color: (category!=-1? category == i : context.bloc<CreateEventCubit>().state.event.category == categoryName) ? black : white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: grey)),
                child: Row(children: <Widget>[
                  new Radio(
                    value: i,
                    activeColor: black_light,
                    groupValue: category,
                    onChanged: (a) => context.bloc<CreateEventCubit>().radioValueChanged(a),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)), color: HexColor(categoryColor)),
                  ),
                  new Text(categoryName.toUpperCase(),
                      style: (category!=-1? category == i : context.bloc<CreateEventCubit>().state.event.category == categoryName) ?
                        subtitle_rev : subtitle.copyWith(color: black)),
                ])), i++)).keys.toList();

    return BlocBuilder<CreateEventCubit, CreateEventState>(
      buildWhen: (previous, current) => previous.category != current.category,
      builder: (context, state) {
        i=0; category = context.bloc<CreateEventCubit>().state.category;
        return Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 5.0, right: 20.0),
                  child: Text("Tipologia", style: title)),
              Expanded(child: Column(children: buildCategoriesList()))
            ],
          ),
        );
      },
    );
  }
}