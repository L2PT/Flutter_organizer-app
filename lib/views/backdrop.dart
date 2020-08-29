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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/events_bloc/events_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/bloc/operators_bloc/operators_bloc.dart';
import 'package:venturiautospurghi/models/linkmenu.dart';
import 'package:venturiautospurghi/utils/global_methods.dart';
import 'package:venturiautospurghi/views/backdrop_menu.dart';
import 'package:venturiautospurghi/views/screen_pages/daily_calendar_view.dart';
import 'package:venturiautospurghi/views/widgets/base_alert.dart';
import 'package:venturiautospurghi/views/widgets/delete_alert.dart';
import 'package:venturiautospurghi/views/widgets/fab_widget.dart';
import 'package:venturiautospurghi/utils/global_contants.dart';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

//HANDLE cambia questa velocità
const double _kFlingVelocity = 2.0;

/// Builds a Screen made of a backlayer and a frontlayer. The backlayer is a menu while the frontlayer is the page content.
/// The content page is decided by the [MobileBloc]
///
/// A Backdrop widget has two layers, front and back. The front layer is shown
/// by default, and slides down to show the back layer, from which a user
/// can make a selection. We can configure a custom interchangable title
/// The route selected is notified to the frontlayer
class Backdrop extends StatefulWidget {
  @override
  _MobileState createState() => _MobileState();
}

class _MobileState extends State<Backdrop> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 100), value: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final account = context.bloc<AuthenticationBloc>().account;
    final bloc = context.bloc<MobileBloc>();
    _toggleBackdropLayerVisibility(false);
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: AppBar(
              title: new Text(
                  (account.supervisor
                          ? (menuResponsabile[bloc.actualRoute] ?? menuResponsabile[Constants.homeRoute])
                          : (menuOperatore[bloc.actualRoute] ?? menuOperatore[Constants.homeRoute]))
                      .textLink
                      .toUpperCase(),
                  style: title_rev),
              elevation: 0.0,
              leading: new IconButton(
                onPressed: () => _toggleBackdropLayerVisibility(true),
                icon: new AnimatedIcon(
                  icon: AnimatedIcons.close_menu,
                  progress: _controller.view,
                ),
              ),
            ),
            floatingActionButton: Fab(),
            body: _buildStack((bloc.state as InBackdropState).content)));
  }

  Widget _buildStack(dynamic content) {
    const double layerTitleHeight = 64.0;
    final Size layerSize = MediaQuery.of(context).size;
    final double layerTop = layerSize.height - layerTitleHeight;

    Animation<RelativeRect> layerAnimation = new RelativeRectTween(
            begin: new RelativeRect.fromLTRB(0.0, layerTop - layerTitleHeight, 0.0, -(layerTop - layerTitleHeight)),
            end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0))
        .animate(new CurvedAnimation(parent: _controller, curve: Curves.linear));
    Animation<RelativeRect> overLayerAnimation = new RelativeRectTween(
            begin: new RelativeRect.fromLTRB(0.0, layerTop - layerTitleHeight, 0.0, 0.0),
            end: new RelativeRect.fromLTRB(0.0, layerTop, 0.0, 0.0))
        .animate(new CurvedAnimation(parent: _controller, curve: Curves.linear));

    return Container(
      child: Stack(
        children: <Widget>[
          ExcludeSemantics(
            child: MenuLayer(),
            excluding: _frontLayerVisible,
          ),
          PositionedTransition(rect: layerAnimation, child: content),
          PositionedTransition(
              rect: overLayerAnimation,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toggleBackdropLayerVisibility(false),
                child: Container(
                  height: 40.0,
                ),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //METODI DI UTILITY
  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed || status == AnimationStatus.forward;
  }

  void _toggleBackdropLayerVisibility(bool button) {
    if (button || !_frontLayerVisible) {
      _controller.fling(velocity: _frontLayerVisible ? -_kFlingVelocity : _kFlingVelocity);
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new Alert(
            title: "ESCI",
            content: new Text( 'Vuoi uscire dall\'app?', style: label, ),
            action: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              FlatButton(
                child: new Text('No', style: label),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              SizedBox( width: 15, ),
              RaisedButton(
                child: new Text('Si', style: button_card),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                color: black,
                elevation: 15,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ]),
          ),
        ) ??
        false;
  }
}
