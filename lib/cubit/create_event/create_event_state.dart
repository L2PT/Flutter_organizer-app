part of 'create_event_cubit.dart';


enum _formStatus { normal, loading, success }

class CreateEventState extends Equatable {
  CreateEventState([this.event]) : this.locations = List<String>.empty() {
    if(event == null) {
      event = Event.empty();
      DateTime nextStartTime = TimeUtils.getNextWorkTimeSpan();
      event.start = nextStartTime.hour == Constants.MIN_WORKTIME? nextStartTime : TimeUtils.addWorkTime( nextStartTime, hour: 1);
      event.end = event.start.add(Duration(minutes: Constants.WORKTIME_SPAN));
    }
    documents = Map<String,PlatformFile>.fromIterable(event.documents, key: (v) => v, value: null);
  }

  Event event;
  List<String> locations;
  Map<String,PlatformFile> documents;
  int category = -1;
  bool isAllDay = false;
  _formStatus status;

  @override
  List<Object> get props => [event.toString(), locations.join(), documents.keys.join(), documents.values.join(), category, status];

  bool isLoading() => this.status == _formStatus.loading;

  CreateEventState assign({
    Event event,
    List<String> locations,
    String address,
    Map<String,PlatformFile> documents,
    int category,
    bool allDayFlag = false,
    _formStatus status,
  }) {
    var form = CreateEventState(event??this.event);
    form.category = category??this.category;
    form.status = status??this.status;
    form.documents = documents??this.documents;
    form.isAllDay = allDayFlag;
    if(!address.isNullOrEmpty()) this.event.address = address;
    form.locations = locations??this.locations;
    return form;
  }
}