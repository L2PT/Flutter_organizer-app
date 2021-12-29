part of 'create_event_cubit.dart';

enum _formStatus { normal, loading, success }

class CreateEventState extends Equatable {
  CreateEventState(Event? e) {
    this.locations = List<String>.empty();
    if(e == null) {
      this.event = Event.empty();
      event.start = TimeUtils.getNextStartWorkTimeSpan();
      event.end = event.start.add(Duration(minutes: Constants.WORKTIME_SPAN));
    } else this.event = e;
    documents = Map<String, dynamic>.fromIterable(event.documents, key: (v) => v, value: (v)=>null);
  }

  late final Event event;
  late List<String> locations;
  late Map<String, dynamic> documents;
  String category = '';
  bool isAllDay = false;
  bool isScheduled = false;
  _formStatus status = _formStatus.normal;
  int currentStep = 0;
  String typeSelected = 'Intervento';

  @override
  List<Object> get props => [event.toString(), locations.join(), documents.keys.join(), documents.values.join(), category, status, isScheduled, currentStep, typeSelected];

  bool isLoading() => this.status == _formStatus.loading;

  CreateEventState assign({
    Event? event,
    List<String>? locations,
    String? address,
    Map<String,dynamic>? documents,
    String? category,
    bool? allDayFlag,
    bool? isScheduled,
    _formStatus? status,
    int? currentStep,
    String? typeSelected,
  }) {
    var form = CreateEventState(event??this.event);
    form.category = category??this.category;
    form.status = status??this.status;
    form.documents = documents??this.documents;
    form.isAllDay = allDayFlag??this.isAllDay;
    form.isScheduled = isScheduled??this.isScheduled;
    if(!string.isNullOrEmpty(address)) form.event.address = address!;
    form.locations = locations??this.locations;
    form.currentStep = currentStep ?? this.currentStep;
    form.typeSelected = typeSelected ?? this.typeSelected;
    return form;
  }
}