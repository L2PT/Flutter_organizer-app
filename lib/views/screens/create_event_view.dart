import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/cubit/create_event_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
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
    Event event = context.bloc<CreateEventCubit>().state.event;

    Widget content = SingleChildScrollView(
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
                child: Icon(Icons.work, color: black, size: iconWidth),
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

    void _onBackPressed() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        context.bloc<MobileBloc>().add(NavigateEvent(Constants.homeRoute, null));
      }
    }

    void _onSavePressed() async {
      if (await context.bloc<CreateEventCubit>().saveEvent())
        Navigator.pop(context);
    }

    return WillPopScope(
        onWillPop: () {
          _onBackPressed;
        },
        child: new Scaffold(
            extendBody: true,
            resizeToAvoidBottomInset: false,
            appBar: new AppBar(
              leading: new BackButton(
                onPressed: _onBackPressed,
              ),
              title: new Text(
                context.bloc<CreateEventCubit>().isNew() ? 'NUOVO EVENTO' : 'MODIFICA EVENTO',
                style: title_rev,
              ),
              actions: <Widget>[
                new Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(15.0),
                    child: RaisedButton(
                      child: new Text('SALVA', style: subtitle_rev),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)), side: BorderSide(color: white)),
                      elevation: 5,
                      onPressed: _onSavePressed,
                    ))
              ],
            ),
            body: new BlocProvider(
              create: (_) => CreateEventCubit(repository, account, _event),
              child: BlocBuilder<CreateEventCubit, CreateEventState>(
                buildWhen: (previous, current) => previous.locations != current.locations,
                builder: (context, state) {
                return context.bloc<CreateEventCubit>().state.isLoading() ?
                  LoadingScreen() : content;   //TODO maybe a success animation can be added
                })
            )
    ));
  }
}

class _geoLocationOptionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> buildAutocompleteList =
    context
        .bloc<CreateEventCubit>()
        .state
        .locations
        .map((location) {
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
        return (context
            .bloc<CreateEventCubit>()
            .state
            .locations) != List<String>.empty() ?
        Row(
          children: <Widget>[
            Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Column(
                    children: buildAutocompleteList,
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
    List<Widget> buildFilesList = context
        .bloc<CreateEventCubit>()
        .state
        .documents
        .keys
        .map((name) {
      return new ListTile(
        title: new Text(name),
        subtitle: new Text(name),
        trailing: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => context.bloc<CreateEventCubit>().removeDocument(name),
        ),
      );
    }).expand((element) => [element, new Divider()]).toList(); //TODO maybe? .removeLast();

    return BlocBuilder<CreateEventCubit, CreateEventState>(
      buildWhen: (previous, current) => previous.documents != current.documents,
      builder: (context, state) {
        return new Container(
          height: 60,
          child: new Scrollbar(
              child: Column(
                children: buildFilesList,
              )),
        );
      },
    );
  }
}

class _timeControls extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Event event;
    double iconWidth = CreateEvent.iconWidth;
    Widget dateTimeStartPicker = Row(children: <Widget>[
      Container(
        width: iconWidth,
        margin: EdgeInsets.only(right: 20.0),
      ),
      Expanded(
        child: GestureDetector(
          child: TextFormField(
            enabled: false,
            cursorColor: black,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                hintText: 'Lun 1 Set ' + DateTime
                    .now()
                    .year
                    .toString(),
                hintStyle: label,
                border: InputBorder.none
            ),
            style: context
                .bloc<CreateEventCubit>()
                .canModify ? title : subtitle,
            initialValue: event.start.toString(),
            validator: (String value) {
              if (value.isNullOrEmpty()) {
                return 'Inserisci una data valida';
              }
              return null;
            },
          ),
          onTap: () =>
          context
              .bloc<CreateEventCubit>()
              .canModify ?
          DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime.now(),
            maxTime: DateTime(3000),
            theme: DatePickerTheme(
                headerColor: black,
                backgroundColor: black_light,
                itemStyle: label,
                doneStyle: subtitle),
            currentTime: event.start,
            locale: LocaleType.it,
            onConfirm: (date) => context.bloc<CreateEventCubit>().setStartDate(date),
          ) : null,
        ),
      ),
      event.isAllDayLong() ? Container()
          : Expanded(
        child: GestureDetector(
          child: TextFormField(
            enabled: false,
            cursorColor: black,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                hintText: '10:00', hintStyle: label, border: InputBorder.none
            ),
            style: context
                .bloc<CreateEventCubit>()
                .canModify ? title : subtitle,
            initialValue: event.start.hour.toString() + " " + event.start.minute.toString(),
            validator: (String value) {
              if (event.isAllDayLong()) return null;
              if (!value.isNullOrEmpty()) {
                DateTime newTime = value as DateTime;
                DateTime now = DateTime.now();
                if (newTime.hour >= Constants.MIN_WORKTIME && newTime.hour < Constants.MAX_WORKTIME &&
                    (TimeUtils.truncateDate(event.start, "day") != TimeUtils.truncateDate(now, "day") ? true :
                    (newTime.hour > now.hour || (newTime.hour == now.hour && newTime.minute > now.minute + 5)))) {
                  return null;
                }
              }
              return 'Inserisci un orario valido';
            },
          ),
          onTap: () =>
          context
              .bloc<CreateEventCubit>()
              .canModify ?
          DatePicker.showTimePicker(context,
            showTitleActions: true,
            currentTime: event.start,
            locale: LocaleType.it,
            onConfirm: (time) => context.bloc<CreateEventCubit>().setStartTime(time),
          ) : null,
        ),
      ),
    ]);

    Widget dateTimeEndPicker = event.isAllDayLong() ? Container()
        : Row(
      children: <Widget>[
        Container(
          width: iconWidth,
          margin: EdgeInsets.only(right: 20.0),
        ),
        Expanded(
          child: GestureDetector(
            child: TextFormField(
              enabled: false,
              cursorColor: black,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  hintText: 'Lun 1 Set ' + DateTime
                      .now()
                      .year
                      .toString(),
                  hintStyle: label,
                  border: InputBorder.none
              ),
              style: context
                  .bloc<CreateEventCubit>()
                  .canModify ? title : subtitle,
              initialValue: event.start.toString(),
              validator: (String value) {
                if (event.isAllDayLong()) return null;
                if (value.isNullOrEmpty()) {
                  return 'Inserisci una data valida';
                }
                return null;
              },
            ),
            onTap: () =>
            context
                .bloc<CreateEventCubit>()
                .canModify ?
            DatePicker.showDatePicker(context,
              showTitleActions: true,
              minTime: TimeUtils.truncateDate(event.start, "day"),
              maxTime: DateTime(3000),
              theme: DatePickerTheme(
                  headerColor: black,
                  backgroundColor: black_light,
                  itemStyle: label,
                  doneStyle: subtitle),
              currentTime: event.start,
              locale: LocaleType.it,
              onConfirm: (date) => context.bloc<CreateEventCubit>().setEndDate(date),
            ) : null,
          ),
        ),
        Expanded(
          child: GestureDetector(
            child: TextFormField(
              enabled: false,
              cursorColor: black,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  hintText: '10:00', hintStyle: label, border: InputBorder.none
              ),
              style: context
                  .bloc<CreateEventCubit>()
                  .canModify ? title : subtitle,
              initialValue: TimeUtils
                  .getNextWorkTimeSpan(event.start.OlderBetween(event.end))
                  .hour
                  .toString() +
                  " - " + TimeUtils
                  .getNextWorkTimeSpan(event.start.OlderBetween(event.end))
                  .minute
                  .toString(),
              validator: (String value) {
                if (event.isAllDayLong()) return null;
                if (!value.isNullOrEmpty()) {
                  DateTime newTime = value as DateTime;
                  DateTime now = DateTime.now();
                  if (newTime.hour >= Constants.MIN_WORKTIME && newTime.hour < Constants.MAX_WORKTIME &&
                      (TimeUtils.truncateDate(event.start, "day") != TimeUtils.truncateDate(now, "day") ? true :
                      (newTime.hour > now.hour || (newTime.hour == now.hour && newTime.minute > now.minute + 5)))) {
                    return null;
                  }
                }
                return 'Inserisci un orario valido';
              },
            ),
            onTap: () =>
            context
                .bloc<CreateEventCubit>()
                .canModify ?
            DatePicker.showTimePicker(context,
              showTitleActions: true,
              currentTime: TimeUtils.getNextWorkTimeSpan(event.start.OlderBetween(event.end)),
              locale: LocaleType.it,
              onConfirm: (time) => context.bloc<CreateEventCubit>().setEndTime(time),
            ) : null,
          ),
        )
      ],
    );

    Widget allDayFlag = Container(
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
                    value: event.isAllDayLong(),
                    activeColor: black,
                    onChanged: context.bloc<CreateEventCubit>().setAlldayLong
                    })) : Container()
          ],));

    return new Form(
      key: context.bloc<CreateEventCubit>().formTimeControlsKey,
      child: BlocBuilder<CreateEventCubit, CreateEventState>(
        buildWhen: (previous, current) => previous.event != current.event,
        builder: (context, state) {
          event = context.bloc<CreateEventCubit>().state.event;
          return Container(child:
          Column(children: <Widget>[
            allDayFlag,
            dateTimeStartPicker,
            dateTimeEndPicker,
          ]));
        },
      )
    );
  }
}

class _operatorsList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<Widget> buildOperatorsList = (context.bloc<CreateEventCubit>().state.event.operator != null
        ? [context.bloc<CreateEventCubit>().state.event.operator, ...context.bloc<CreateEventCubit>().state.event.suboperators]
        : context.bloc<CreateEventCubit>().state.event.suboperators).map((operator) {
      Account entity = Account.fromMap("", operator);
      return Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 15),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10.0),
              padding: EdgeInsets.all(3.0),
              child: Icon(Icons.work, color: yellow),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: black,
              ),
            ),
            Text(entity.surname.toUpperCase() + " ", style: title),
            Text(entity.name, style: subtitle),
            Expanded(
              child: Container(),
            ),
            operator != context.bloc<CreateEventCubit>().state.event.operator && context.bloc<CreateEventCubit>().canModify ?
            IconButton(
              icon: Icon(Icons.delete, color: black, size: 25),
              onPressed: () => context.bloc<CreateEventCubit>().removeSuboperatorFromEventList(entity)
            ) : Container()
          ],
        ),
      );
    }).toList();

    return BlocBuilder<CreateEventCubit, CreateEventState>(
      buildWhen: (previous, current) => previous.event != previous.event,
      builder: (context, state) {
        return Container(child: Column(children: buildOperatorsList));
      },
    );
  }
}

class _categoriesList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Map<String, String> categories = context
        .bloc<CreateEventCubit>()
        .categories;
    int i = 0;
    List<Widget> buildCategoriesList = categories.map((categoryName, categoryColor) =>
        MapEntry(GestureDetector(
            onTap: () => context.bloc<CreateEventCubit>().radioValueChanged(i),
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    color: (context
                        .bloc<CreateEventCubit>()
                        .state
                        .category == i) ? black : white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: grey)),
                child: Row(children: <Widget>[
                  new Radio(
                    value: i,
                    activeColor: black_light,
                    groupValue: context
                        .bloc<CreateEventCubit>()
                        .state
                        .category,
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
                      style: (context
                          .bloc<CreateEventCubit>()
                          .state
                          .category == i) ? subtitle_rev : subtitle.copyWith(color: black)),
                ]))), i++)).keys.toList();

    return BlocBuilder<CreateEventCubit, CreateEventState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 5.0, right: 20.0),
                  child: Text("Tipologia", style: title)),
              Expanded(child: Column(children: buildCategoriesList))
            ],
          ),
        );
      },
    );
  }
}