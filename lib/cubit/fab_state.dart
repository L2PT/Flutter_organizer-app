part of 'fab_cubit.dart';

class FabState extends Equatable {
  const FabState(this.route, this.isSupervisor);

  final String route;
  final bool isSupervisor;

  @override
  List<Object> get props => [route, isSupervisor];
}