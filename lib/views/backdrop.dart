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
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/views/backdrop_menu.dart';
import 'package:venturiautospurghi/views/widgets/base_alert.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
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
class Backdrop extends StatefulWidget{
  @override
  _MobileState createState() => _MobileState();
}


class _MobileState extends State<Backdrop> with SingleTickerProviderStateMixin, WidgetsBindingObserver{
  late AnimationController _controller;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<MobileBloc>().lifecycleState = state; // TODO is this useless
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 100), value: 1.0, vsync: this);
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final account = context.read<AuthenticationBloc>().account!; // TODO check
    final state = context.read<MobileBloc>().state is InBackdropState ? context.watch<MobileBloc>().state : context.watch<MobileBloc>().savedState; // TODO
    _toggleBackdropLayerVisibility(false);
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: AppBar(
              title: new Text(
                  (account.supervisor ?
                  (menuResponsabile[state.route] ?? menuResponsabile[Constants.homeRoute]) :
                  (menuOperatore[state.route] ?? menuOperatore[Constants.homeRoute]))!
                      .textLink.toUpperCase(),
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
            floatingActionButton: Container(),//Fab(),
            body: _buildStack((state as InBackdropState).content)));
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
            child: MenuLayer(_toggleBackdropLayerVisibility),
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
    WidgetsBinding.instance?.removeObserver(this);
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

  Future<bool> _onBackPressed() async { //TODO check
    bool ret = false;
    if(context.read<MobileBloc>().state is OutBackdropState)
      PlatformUtils.backNavigator(context);
    else
      ret = (await showDialog(
          context: context,
          builder: (context) => new Alert(
            title: "ESCI",
            content: new Text( 'Vuoi uscire dall\'app?', style: label, ),
            actions: <Widget>[
              TextButton(
                child: new Text('No', style: label),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              SizedBox( width: 15, ),
              ElevatedButton(
                child: new Text('Si', style: button_card),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        )) ?? false;
    return Future<bool>(()=>ret);
  }
}
