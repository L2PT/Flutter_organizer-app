part of 'details_event_cubit.dart';

class DetailsEventState extends Equatable {
  DetailsEventState(this.event, this.notaOperator, this.status, this.listDocuments);

  final Event event;
  String notaOperator = '';
  int status;
  List<String> listDocuments;

  @override
  List<Object> get props => [event.toString(), notaOperator, status, listDocuments.join()];

  DetailsEventState changeStatus(int status) =>
      DetailsEventState(this.event, this.notaOperator, status, this.listDocuments)..event.status = status;

  DetailsEventState changeNotaOperator(String notaOperator) =>
    DetailsEventState(this.event, notaOperator, this.status, this.listDocuments)..event.notaOperator = notaOperator;

  DetailsEventState changeListDocuments(List<String> listDocuments) =>
      DetailsEventState(this.event, notaOperator, this.status, listDocuments)..event.documents = listDocuments;

}