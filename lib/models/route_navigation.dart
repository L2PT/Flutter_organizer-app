import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/utils/create_entity_utils.dart';

class RouteNavigation extends Equatable{

  String route = '';
  int currentStep = 0;
  TypeStatus status = TypeStatus.create;
  Function? callback;

  RouteNavigation(this.route,this.currentStep,this.status, [this.callback]);
  RouteNavigation.empty();

  void update(RouteNavigation routeUpdate) {
    this.route = routeUpdate.route;
    this.currentStep = routeUpdate.currentStep;
    this.callback = routeUpdate.callback;
    this.status = routeUpdate.status;
  }

  @override
  List<Object?> get props => [route, currentStep, callback, status];

}