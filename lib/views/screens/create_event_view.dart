import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/cubit/create_event/create_event_cubit.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/colors.dart';
import 'package:venturiautospurghi/utils/extensions.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/views/widgets/loading_screen.dart';
import 'package:venturiautospurghi/views/widgets/platform_datepicker.dart';
import 'package:venturiautospurghi/views/widgets/success_alert.dart';

class CreateEvent extends StatelessWidget {
  final Event? _event;
  static const iconWidth = 30.0; //HANDLE

  CreateEvent([this._event]);

  @override
  Widget build(BuildContext context) {
    var repository = RepositoryProvider.of<CloudFirestoreService>(context);
    var account = BlocProvider.of<AuthenticationBloc>(context).account!;

    return new BlocProvider(
        create: (_) => CreateEventCubit(repository, account, _event),
        child: WillPopScope(
            onWillPop: ()=>PlatformUtils.backNavigator(context),
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
                      return context.select((CreateEventCubit cubit) => cubit.state.isLoading())?
                      LoadingScreen() : _formInputList();
                    })
        ))
    );
  }
}

class _viewHeader extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    void _onSavePressed(BuildContext context) async {
      if (await context.read<CreateEventCubit>().saveEvent())
        if( !(await SuccessAlert(context, text: "Incarico salvato e inviato!").show()))
          PlatformUtils.backNavigator(context);
    }

    return new Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(15.0),
      child: ElevatedButton(
        child: new Text('SALVA', style: subtitle_rev),
        style: raisedButtonStyle.copyWith(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0))),
        ),
        onPressed: ()=> _onSavePressed(context),
      ));
  }
}

class _formInputList extends StatelessWidget{
  double iconWidth = CreateEvent.iconWidth;

  @override
  Widget build(BuildContext context) {
    Event event = context.read<CreateEventCubit>().state.event;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: new Form(
          key: context.read<CreateEventCubit>().formKey,
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
                validator:(value) => string.isNullOrEmpty(value)?
                  'Il campo \'Titolo\' è obbligatorio' : null,
                onSaved: (value) => event.title = value??"",
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
                  onSaved: (value) => event.description = value??"",
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
                    onChanged: (text) => context.read<CreateEventCubit>().getLocations(text),
                    keyboardType: TextInputType.text,
                    cursorColor: black,
                    controller: context.read<CreateEventCubit>().addressController,
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
                child: Text("Aggiungi documenti", style: label,),
              ),
              IconButton(
                  icon: Icon(Icons.add, color: black),
                  onPressed: () => context.read<CreateEventCubit>().openFileExplorer()
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
                    child: Text(context.read<CreateEventCubit>().canModify ? "Aggiungi operatore" : "Operatori",
                        style: label)),
              ),
              context.read<CreateEventCubit>().canModify ? IconButton(
                  icon: Icon(Icons.add, color: black),
                  onPressed: () => context.read<CreateEventCubit>().addOperatorDialog(context)
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
    context.read<CreateEventCubit>().state.locations.map((location) {
      return GestureDetector(
          onTap: () => context.read<CreateEventCubit>().setAddress(location),
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
        return (context.read<CreateEventCubit>().state.locations) != List<String>.empty() ?
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
      itemCount: context.read<CreateEventCubit>().state.documents.keys.length,
      itemBuilder: (context, index) =>
          ListTile(
            leading: IconButton(icon: Icon(Icons.insert_drive_file, color: black,), onPressed: null,),
            title: new Text(context.read<CreateEventCubit>().state.documents.keys.elementAt(index)),
            subtitle: new Text(context.read<CreateEventCubit>().state.documents.values.elementAt(index) == null?"Già caricato":"Nuovo", style: subtitle,),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: black,),
              onPressed: () => context.read<CreateEventCubit>().removeDocument(context.read<CreateEventCubit>().state.documents.keys.elementAt(index)),
            ),
          )
    );

    return BlocBuilder<CreateEventCubit, CreateEventState>(
      buildWhen: (previous, current) => previous.documents != current.documents,
      builder: (context, state) {
        return context.read<CreateEventCubit>().state.documents.keys.length > 0? new Container(
          height: 60,
          child: buildFilesList()
        ): Container();
      },
    );
  }
}

class _timeControls extends StatelessWidget { //TODO debug session need to check if this works as supposed to work 

  @override
  Widget build(BuildContext context) {
    Event event = context.watch<CreateEventCubit>().state.event;
    double iconWidth = CreateEvent.iconWidth;

    Widget dateTimeStartPicker() => Row(children: <Widget>[
      Container(
        width: iconWidth,
        margin: EdgeInsets.only(right: 20.0),
      ),
      Expanded(
        child: GestureDetector(
          child: Text( event.start.toString().split(' ').first,
            style: context.read<CreateEventCubit>().canModify ? title : subtitle),
          onTap: () => context.read<CreateEventCubit>().canModify ?
          PlatformDatePicker.selectDate(context,
            maxTime: DateTime(3000),
            currentTime: event.start,
            onConfirm: (date) => context.read<CreateEventCubit>().state.isAllDay?
              context.read<CreateEventCubit>().setAllDayDate(date):context.read<CreateEventCubit>().setStartDate(date),
          ) : null,
        ),
      ),
      context.read<CreateEventCubit>().state.isAllDay ? Container()
          : Expanded(
        child: GestureDetector(
          child: Text( event.start.toString().split(' ').last.split('.').first.substring(0,5),
            style: context.read<CreateEventCubit>().canModify ? title : subtitle),
          onTap: () => context.read<CreateEventCubit>().canModify ?
          PlatformDatePicker.selectTime(context,
            currentTime: event.start,
            onConfirm: (time) => {context.read<CreateEventCubit>().setStartTime(time)},
          ) : null,
        ),
      ),
    ]);
    
    Widget dateTimeEndPicker() => context.read<CreateEventCubit>().state.isAllDay ? Container()
        : Row(
      children: <Widget>[
        Container(
          width: iconWidth,
          margin: EdgeInsets.only(right: 20.0),
        ),
        Expanded(
          child: GestureDetector(
            child: Text(event.end.toString().split(' ').first,
              style: context.read<CreateEventCubit>().canModify ? title : subtitle,),
            onTap: () => context.read<CreateEventCubit>().canModify ?
            PlatformDatePicker.selectDate(context,
              minTime: TimeUtils.truncateDate(event.start, "day"),
              maxTime: DateTime(3000),
              currentTime: event.end,
              onConfirm: (date) => context.read<CreateEventCubit>().setEndDate(date),
            ) : null,
          ),
        ),
        Expanded(
          child: GestureDetector(
            child: Text(event.end.toString().split(' ').last.split('.').first.substring(0,5),
              style: context.read<CreateEventCubit>().canModify ? title : subtitle,
            ),
            onTap: () => context.read<CreateEventCubit>().canModify ?
              PlatformDatePicker.selectTime(context,
                currentTime: event.end,
                onConfirm: (time) => context.read<CreateEventCubit>().setEndTime(time),
              ) : null,
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
                  .read<CreateEventCubit>()
                  .canModify ? "Tutto il giorno" : "Orario", style: label),
            ),
            context.read<CreateEventCubit>().canModify ?
              Container(
                alignment: Alignment.centerRight,
                child: Switch(
                    value: context.read<CreateEventCubit>().state.isAllDay,
                    activeColor: black,
                    onChanged: context.read<CreateEventCubit>().setAlldayLong
                    )) : Container()
          ],));


    Widget eventScheduled() => Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: iconWidth,
            margin: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.date_range_rounded, color: black, size: iconWidth),
          ),
          Expanded(
              child: Text("Incarico programmato", style: label,),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Switch(
              value: context.read<CreateEventCubit>().state.isScheduled,
              activeColor: black,
              onChanged: context.read<CreateEventCubit>().setIsScheduled,
            ),
          )
        ],
      ),
    );

    return new Form(
      key: context.read<CreateEventCubit>().formTimeControlsKey,
      child: Container(child:
          Column(children: <Widget>[
            context.read<CreateEventCubit>().canModify? eventScheduled() : Container(),
            allDayFlag(),
            dateTimeStartPicker(),
            dateTimeEndPicker(),
          ])
      ) 
    );
  }
}

class _operatorsList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<Widget> buildOperatorsList() => (context.read<CreateEventCubit>().state.event.operator != null
        ? [context.read<CreateEventCubit>().state.event.operator!, ...context.read<CreateEventCubit>().state.event.suboperators]
        : context.read<CreateEventCubit>().state.event.suboperators).map((operator) {
      return Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 15),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10.0),
              padding: EdgeInsets.all(3.0),
              child: Icon(operator.supervisor?FontAwesomeIcons.userTie:FontAwesomeIcons.hardHat, color: yellow),
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
            operator != context.read<CreateEventCubit>().state.event.operator && context.read<CreateEventCubit>().canModify ?
            IconButton(
              icon: Icon(Icons.delete, color: black, size: 25),
              onPressed: () => context.read<CreateEventCubit>().removeSuboperatorFromEventList(operator)
            ) : Container()
          ],
        ),
      );
    }).toList();

    return BlocBuilder<CreateEventCubit, CreateEventState>(
      buildWhen: (previous, current) => previous.event.toString() != current.event.toString(),
      builder: (context, state) {
        return Container(child: Column(children: buildOperatorsList()));
      },
    );
  }
}

class _categoriesList extends StatelessWidget { //TODO debug session need to check if this works as supposed to work 

  @override
  Widget build(BuildContext context) {
    int i = 0;
    int category = context.select((CreateEventCubit cubit)=>cubit.state.category);

    List<Widget> buildCategoriesList() => context.read<CreateEventCubit>().categories.map((categoryName, categoryColor) =>
        MapEntry( Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    color: (category!=-1? category == i : context.read<CreateEventCubit>().state.event.category == categoryName) ? black : white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: grey)),
                child: Row(children: <Widget>[
                  new Radio(
                    value: i,
                    activeColor: black_light,
                    groupValue: category,
                    onChanged: (int? val) => context.read<CreateEventCubit>().radioValueChanged(val!),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)), color: HexColor(categoryColor)),
                  ),
                  new Text(categoryName.toUpperCase(),
                      style: (category!=-1? category == i : context.read<CreateEventCubit>().state.event.category == categoryName) ?
                        subtitle_rev : subtitle.copyWith(color: black)),
                ])), i++)).keys.toList();
    
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
  }
}