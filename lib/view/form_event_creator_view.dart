
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:venturiautospurghi/plugin/dispatcher/platform_loader.dart';
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
  final dateFormat = DateFormat("MMMM d, yyyy 'at' h:mma");
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final titleWidget = new TextFormField(
      keyboardType: TextInputType.text,
      decoration: new InputDecoration(
          hintText: 'Event Name',
          labelText: 'Event Title',
          contentPadding: EdgeInsets.all(16.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
          )
      ),
      initialValue: widget._event.title,
      style: Theme.of(context).textTheme.headline,
      validator: this._validateTitle,
      onSaved: (String value) => widget._event.title = value,
    );

    final notesWidget = new TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Notes',
        labelText: 'Enter your notes here',
        contentPadding: EdgeInsets.all(16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0)
        )
      ),
      initialValue: widget._event.description,
      style: Theme.of(context).textTheme.headline,
      onSaved: (String value) => widget._event.description = value,
    );
    
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
              titleWidget,
              SizedBox(height: 16.0),
              new DateTimePickerFormField(
                initialDate: widget._event.start,
                initialValue: widget._event.start,
                inputType: InputType.both,
                format: dateFormat,
                keyboardType: TextInputType.datetime,
                style: TextStyle(fontSize: 20.0, color: Colors.black),
                editable: true,
                decoration: InputDecoration(
                    labelText: 'Event Date',
                    hintText: 'August 1, 2019 at 1:00PM',
                    contentPadding: EdgeInsets.all(20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0)
                    )
                ),
                autovalidate: false,
                validator: this._validateDate,
                onSaved: (DateTime value) => widget._event.start = value,
              ),
              SizedBox(height: 16.0),
              notesWidget,
            ],
          ),
        )

      ),
    );
  }
  
  String _validateTitle(String value) {
    if (value.isEmpty) {
      return 'Please enter a valid title.';
    } else {
      return null;
    }
  }

  String _validateDate(DateTime value) {
    if ( (value != null)
        && (value.day >= 1 && value.day <= 31)
        && (value.month >= 1 && value.month <= 12)
        && (value.year >= 2015 && value.year <= 3000)) {
      return null;
    } else {
      return 'Please enter a valid event date.';
    }
  }

  Future _saveNewEvent(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      print("Firebase save");
      PlatformUtils.fire.collection("Eventi").add(widget._event.toMap());
      PlatformUtils.notify();
      Navigator.maybePop(context);
    }
  }

}