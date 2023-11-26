part of 'web_cubit.dart';

class WebCubitState extends Equatable {

  DateTime calendarDate;
  List<Account> webops = [];
  bool expandedMode = true;
  Map<String,List<Event>> eventsOpe = {};

  WebCubitState({  bool expandedMode = true, List<Account>? webops, DateTime? calendarDate, Map<String,List<Event>>? eventsOpe }):
              this.calendarDate = calendarDate??DateTime.now(),
              this.expandedMode = expandedMode,
              this.webops = webops??[],
              this.eventsOpe = eventsOpe??{};

  @override
  List<Object?> get props => [ expandedMode, calendarDate,  webops, eventsOpe.entries];

  ReadyWebCubitState assign({
    bool? expandedMode,
    DateTime? calendarDate,
    List<Account>? webops,
    Map<String,List<Event>>? eventsOpe,
  }) => ReadyWebCubitState.update(
      expandedMode??this.expandedMode, calendarDate??this.calendarDate, webops??this.webops,
      eventsOpe??this.eventsOpe);

}

class LoadingWebCubitState extends WebCubitState{
  @override
  List<Object> get props => [];
}

class ReadyWebCubitState extends WebCubitState{


  ReadyWebCubitState([List<Account>? webops]): super(webops: webops);

  @override
  List<Object?> get props => [expandedMode, calendarDate,  webops, eventsOpe.entries];

  ReadyWebCubitState.update(bool expandedMode, DateTime? calendarDate, List<Account> webops, Map<String,List<Event>> eventsOpe):
        super(expandedMode: expandedMode, webops: webops, calendarDate: calendarDate, eventsOpe: eventsOpe);

  List<Event> selectedEventsOperator(String idOperator) {
    return eventsOpe[idOperator]??[];
  }

}