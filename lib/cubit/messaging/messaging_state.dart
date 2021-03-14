part of 'messaging_cubit.dart';

enum _messagesQueuetatus { empty, waiting }

class MessagingState extends Equatable {
  MessagingState({this.event, _messagesQueuetatus? status}) : this.status = status ?? _messagesQueuetatus.empty;

  final Event? event;
  final int rand = Random.secure().nextInt(100000);
  final _messagesQueuetatus status;

  @override
  List<Object> get props => [rand];

  bool isWaiting() => this.status == _messagesQueuetatus.waiting;

  MessagingState assign({
    Event? event,
  }) => MessagingState(event: event, status: _messagesQueuetatus.waiting);
  
  MessagingState signOut() // TODO must be called or the bloc recreate at auth -> unauth -> auth
    => MessagingState(status:_messagesQueuetatus.empty);
}