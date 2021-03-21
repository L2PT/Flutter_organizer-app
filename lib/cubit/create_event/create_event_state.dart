part of 'create_event_cubit.dart';

enum _formStatus { normal, loading, success }

class CreateEventState extends Equatable {
  CreateEventState(Event? e) {
    this.locations = List<String>.empty();
    if(e == null) {
      this.event = Event.empty();
      DateTime nextStartTime = TimeUtils.getNextWorkTimeSpan();
      event.start = nextStartTime.hour == Constants.MIN_WORKTIME? nextStartTime : TimeUtils.addWorkTime( nextStartTime, hour: 1);
      event.end = event.start.add(Duration(minutes: Constants.WORKTIME_SPAN));
    } else this.event = e;
    documents = Map<String, File?>.fromIterable(event.documents, key: (v) => v, value: (v)=>null);
  }

  late final Event event;
  late List<String> locations;
  late Map<String, File?> documents;
  int category = -1;
  bool isAllDay = false;
  bool isScheduled = false;
  _formStatus status = _formStatus.normal;

  @override
  List<Object> get props => [event.toString(), locations.join(), documents.keys.join(), documents.values.join(), category, status, isScheduled];

  bool isLoading() => this.status == _formStatus.loading;

  CreateEventState assign({
    Event? event,
    List<String>? locations,
    String? address,
    Map<String,File?>? documents,
    int? category,
    bool? allDayFlag,
    bool? isScheduled,
    _formStatus? status
  }) {
    var form = CreateEventState(event??this.event);
    form.category = category??this.category;
    form.status = status??this.status;
    form.documents = documents??this.documents;
    form.isAllDay = allDayFlag??this.isAllDay;
    form.isScheduled = isScheduled??this.isScheduled;
    if(!string.isNullOrEmpty(address)) form.event.address = address!;
    form.locations = locations??this.locations;
    return form;
  }
}