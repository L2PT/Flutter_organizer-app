// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/models/linkMenu.dart';
import 'package:venturiautospurghi/utils/global_contants.dart' as global;
import 'package:flutter/material.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:meta/meta.dart';
import 'package:venturiautospurghi/view/waiting_event_view.dart';
import '../models/event.dart';
import '../utils/theme.dart';
import 'form_event_creator_view.dart';
import 'monthly_calendar_view.dart';
import 'daily_calendar_view.dart';
import 'operator_list_view.dart';
import 'user_profile_view.dart';
import 'details_event_view.dart';

//HANDLE cambia questa velocità
const double _kFlingVelocity = 2.0;

final Map<String, LinkMenu> _menuOperatore = const {
  global.Constants.homeRoute:
      const LinkMenu(Icons.home, Colors.white, 30, "Home", title_rev),
  global.Constants.waitingEventListRoute: const LinkMenu(Icons.visibility_off,
      Colors.white, 30, "Incarichi in sospeso", title_rev),
  global.Constants.monthlyCalendarRoute: const LinkMenu(
      FontAwesomeIcons.calendarAlt, Colors.white, 25, "Calendario", title_rev)
};

final Map<String, LinkMenu> _menuResponsabile = const {
  global.Constants.homeRoute:
      const LinkMenu(Icons.home, Colors.white, 16, "Home", title_rev),
};

/// Builds a Backdrop.
///
/// A Backdrop widget has two layers, front and back. The front layer is shown
/// by default, and slides down to show the back layer, from which a user
/// can make a selection. We can configure a custom interchangable title
/// The route selected is notified to the frontlayer
class Backdrop extends StatefulWidget {
  final String frontLayerRoute;
  final Object frontLayerArg;
  final Function backLayerRouteChanger;
  final bool isLoggedIn;
  final bool isSupervisor;

  const Backdrop({
    @required this.backLayerRouteChanger,
    @required this.frontLayerRoute,
    @required this.frontLayerArg,
    @required this.isLoggedIn,
    @required this.isSupervisor,
  })  : assert(frontLayerRoute != null),
        assert(backLayerRouteChanger != null);

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: "Backdrop");
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 100), value: 1.0, vsync: this);
  }

  @override
  void didUpdateWidget(Backdrop old) {
    print(widget.frontLayerArg);
    print("backdrop up");
    super.didUpdateWidget(old);
    if (widget.frontLayerRoute != old.frontLayerRoute) {
      _toggleBackdropLayerVisibility(true);
    }/* else if (!_frontLayerVisible) {
      _controller.fling(velocity: _kFlingVelocity);
    }*/
    Timer.run(() {
      if (widget.isLoggedIn == false) {
        Navigator.of(context).pushReplacementNamed(global.Constants.logInRoute);
      }
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

      //MAIN BUILEDER METHODS
        //--APPBAR DELLA BACKDROP
  //TODO spostare il controllo della route dal FrontLayer alla backdrop per fare il Fab custom
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(
            widget.isSupervisor
                ? _menuResponsabile[widget.frontLayerRoute]
                .textLink
                .toUpperCase()
                : _menuOperatore[widget.frontLayerRoute]
                .textLink
                .toUpperCase(),
            style: title_rev),
        elevation: 0.0,
        leading: new IconButton(
          onPressed: ()=>_toggleBackdropLayerVisibility(true),
          icon: new AnimatedIcon(
            icon: AnimatedIcons.close_menu,
            progress: _controller.view,
          ),
        ),
      ),
      floatingActionButton:  _FabChooser(),
      body: LayoutBuilder(
        builder: _buildStack2,
      ),
    );
  }

  //--BUILDER DELL' OVERLAP DEI DUE LAYER
  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 48.0; //HANDLE
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;

    Animation<RelativeRect> layerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0, layerTop, 0.0, layerTop - layerSize.height),
      end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_controller.view);
    return Stack(
      key: _backdropKey,
      children: <Widget>[
        ExcludeSemantics(
          child: _BackLayer(
            onTap: widget.backLayerRouteChanger,
            currentViewR: widget.frontLayerRoute,
            isSupervisor: widget.isSupervisor,
          ),
          excluding: _frontLayerVisible,
        ),
        PositionedTransition(
          rect: layerAnimation,
          child: _FrontLayer(
            onTap: () => _toggleBackdropLayerVisibility(false),
            flag: _frontLayerVisible,
            route: widget.frontLayerRoute,
            arguments: widget.frontLayerArg,
            isSupervisor: widget.isSupervisor,
          ),
        ),
      ],
    );
  }

  Widget _buildStack2(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 48.0;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;

    const header_height = 32.0;
    final height = constraints.biggest.height;
    final backPanelHeight = height - header_height;
    final frontPanelHeight = -header_height;

    Animation<RelativeRect> layerAnimation = new RelativeRectTween(
            begin: new RelativeRect.fromLTRB(
                0.0, backPanelHeight, 0.0, frontPanelHeight),
            end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0))
        .animate(
            new CurvedAnimation(parent: _controller, curve: Curves.linear));

    return Container(
      child: Stack(
        key: _backdropKey,
        children: <Widget>[
          ExcludeSemantics(
            child: _BackLayer(
              onTap: widget.backLayerRouteChanger,
              currentViewR: widget.frontLayerRoute,
              isSupervisor: widget.isSupervisor,
            ),
            excluding: _frontLayerVisible,
          ),
          PositionedTransition(
            rect: layerAnimation,
            child: _FrontLayer(
              onTap: () => _toggleBackdropLayerVisibility(false),
              flag: _frontLayerVisible,
              route: widget.frontLayerRoute,
              arguments: widget.frontLayerArg,
              isSupervisor: widget.isSupervisor,
            ),
          ),
          Visibility(
            child: Container(
              color: whiteoverlapbackground,
              child: Center(
                child: Loading(indicator: BallPulseIndicator(), size: 100.0),
              ),
            ),
            visible: widget.isLoggedIn == null,
          ),
        ],
      ),
    );
  }

      //METODI DI UTILITY
  Widget _FabChooser(){
    if(widget.frontLayerRoute == global.Constants.detailsEventViewRoute){
      if(widget.isSupervisor) {
        return FloatingActionButton(
          child: Icon(FontAwesomeIcons.clipboardList),
          onPressed: _showDialogFabSupervisor,
          backgroundColor: dark,
        );
      }else {
        return FloatingActionButton(
          child: Icon(FontAwesomeIcons.phone),
          onPressed: _showDialogFabOperator,
          backgroundColor: dark,
        );
      }
    }else{
      return null;
    }
  }

  void _showDialogFabSupervisor() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(20.0),
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical:5.0),
                  child:
                    Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Cancella", style: customLightTheme.textTheme.title.copyWith(color: white)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){},
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dark,
                          ),
                          child: Icon(FontAwesomeIcons.trashAlt),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical:5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Modifica", style: customLightTheme.textTheme.title.copyWith(color: white)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){},
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dark,
                          ),
                          child: Icon(FontAwesomeIcons.pencilAlt),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 65,)
              ],
            )
          );
        }
    );
  }
  void _showDialogFabOperator() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(20.0),
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical:5.0),
                  child:
                    Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Responsabile", style: customLightTheme.textTheme.title.copyWith(color: white)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){},
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dark,
                          ),
                          child: Icon(FontAwesomeIcons.userTie),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical:5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Ufficio", style: customLightTheme.textTheme.title.copyWith(color: white)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){},
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dark,
                          ),
                          child: Icon(FontAwesomeIcons.building),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 65,)
              ],
            )
          );
        }
    );
  }

  //METODI DI UTILITY
  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropLayerVisibility(bool button) {
    if (button || !_frontLayerVisible) {
      _controller.fling(
          velocity: _frontLayerVisible ? -_kFlingVelocity : _kFlingVelocity);
    }
  }
}

//////THIS CLASS IS CUSTOM POSSIAMO ELIMINARLA SE NON SERVE//////
class _CustomTitle extends AnimatedWidget {
  final Widget frontTitle;
  final Widget backTitle;

  const _CustomTitle({
    Key key,
    Listenable listenable,
    @required this.frontTitle,
    @required this.backTitle,
  })  : assert(frontTitle != null),
        assert(backTitle != null),
        super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.listenable;

    return Stack(
      children: <Widget>[
        Opacity(
          opacity: CurvedAnimation(
            parent: ReverseAnimation(animation),
            curve: Interval(0.5, 1.0),
          ).value,
          child: FractionalTranslation(
            translation: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(0.5, 0.0),
            ).evaluate(animation),
            child: Semantics(
                label: 'hide categories menu',
                child: ExcludeSemantics(child: backTitle)),
          ),
        ),
        Opacity(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Interval(0.5, 1.0),
          ).value,
          child: FractionalTranslation(
            translation: Tween<Offset>(
              begin: Offset(-0.25, 0.0),
              end: Offset.zero,
            ).evaluate(animation),
            child: Semantics(
                label: 'show categories menu',
                child: ExcludeSemantics(child: frontTitle)),
          ),
        ),
      ],
    );
  }
}
/////////////////////////////////////////////////////////////////




/// Builds a BackLayer.
///
/// The backlayer contains the menu with all the choices of the user
///
///
///
class _BackLayer extends StatelessWidget {//TODO poluzzi
  //ROUTES

  const _BackLayer({
    Key key,
    this.onTap,
    this.currentViewR,
    this.isSupervisor,
  })  : assert(currentViewR != null),
        super(key: key);

  final ValueChanged<String> onTap;
  final String currentViewR;
  final bool isSupervisor;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: dark,
        child: Column(
          children: <Widget>[
            Expanded(
              child: new ListView(
                  physics: new BouncingScrollPhysics(),
                  children: (isSupervisor ? _menuResponsabile : _menuOperatore)
                      .map((route, linkMenu) =>
                          _buildMenu(linkMenu, route, context))
                      .values
                      .toList()),
            ),
            Expanded(
              child: Container(
                child: GestureDetector(
                  onTap: () => onTap(global.Constants.logOut),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.doorOpen,
                        color: Colors.white,
                        size: 20,
                        semanticLabel: 'Icon menu',
                      ),
                      SizedBox(width: 15.0),
                      Text("Esci", style: title_rev),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

  //TODO aspettanndo il layout di Turro
  MapEntry<String, Widget> _buildMenu(
      LinkMenu view, String route, BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new MapEntry(
        route,
        GestureDetector(
          onTap: () => onTap(route),
          child: currentViewR == route
              ? Column(
                  children: <Widget>[
                    SizedBox(height: 16.0),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[

                              Icon(
                                view.iconLink,
                                color: view.colorIcon,
                                size: view.sizeIcon,
                                semanticLabel: 'Icon menu',
                              ),
                              SizedBox(width: 15.0),
                              Container(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 5.0),
                                  child: Text(
                                    view.textLink,
                                    style: title_rev,
                                  ),
                                ),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                            color: yellow,
                                            width: 2.0,
                                          )))
                               ),

                            ],
                          ),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        view.iconLink,
                        color: view.colorIcon,
                        size: view.sizeIcon,
                        semanticLabel: 'Icon menu',
                      ),
                      SizedBox(width: 15.0),
                      Text(view.textLink, style: title_rev),
                    ],
                  ),
                ),
        ));
  }
}





/// Builds a FrontLayer.
///
/// The frontlayer contains the page associated with the selected route.
/// and the UI specific for the role of the user.
/// L'onTap chiude il menu a discesa
/// La route viene gestita in modo da caricare la classe corretta in base
/// al rouolo dell' utente
//TODO rounded corner da decidere aspettando il layout di Turro
class _FrontLayer extends StatelessWidget {
  const _FrontLayer({
    Key key,
    this.onTap,
    this.flag,
    this.route,
    this.arguments,
    this.isSupervisor,
  }) : super(key: key);

  final VoidCallback onTap;
  final bool flag;
  final String route;
  final Object arguments;
  final Object isSupervisor;

  Widget router(){
    print(arguments);
    print(route);
    print("frontlayer");
    switch(route) {
      case global.Constants.homeRoute: {
        if(isSupervisor) return OperatorList();
        else return DailyCalendar();}
      break;
      case global.Constants.monthlyCalendarRoute: {return MonthlyCalendar();}
      break;
      case global.Constants.dailyCalendarRoute: {return DailyCalendar(day:arguments);}
      break;
      case global.Constants.profileRoute: {return Profile();}
      break;
      case global.Constants.operatorListRoute: {return OperatorList();}
      break;
      case global.Constants.detailsEventViewRoute: {return arguments!=null?DetailsEvent(event: arguments):null;}
      break;
      case global.Constants.formEventCreatorRoute: {return EventCreator(null);}
      break;
      case global.Constants.waitingEventListRoute: {return waitingEvent();}
      break;
      default: {return DailyCalendar();}
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        router(),
        Visibility(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: 40.0,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          visible: !flag,
          maintainSize: false,
        )
      ],
    );
  }
}
