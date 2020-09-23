import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venturiautospurghi/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:venturiautospurghi/bloc/mobile_bloc/mobile_bloc.dart';
import 'package:venturiautospurghi/models/linkmenu.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final Map<String, LinkMenu> menuOperatore = const {
  Constants.homeRoute: const LinkMenu(Icons.home, Colors.white, 30, "Home", title_rev),
  Constants.waitingEventListRoute: const LinkMenu(Icons.visibility_off, Colors.white, 30, "Incarichi in sospeso", title_rev),
  Constants.monthlyCalendarRoute: const LinkMenu(FontAwesomeIcons.calendarAlt, Colors.white, 25, "Calendario", title_rev)
};

final Map<String, LinkMenu> menuResponsabile = const {
  Constants.homeRoute: const LinkMenu(Icons.home, Colors.white, 30, "Home", title_rev),
  Constants.historyEventListRoute: const LinkMenu(Icons.history, Colors.white, 30, "Storico incarichi", title_rev),
  Constants.createEventViewRoute: const LinkMenu(Icons.edit, Colors.white, 30, "Crea evento", title_rev),
  Constants.registerRoute: const LinkMenu(Icons.person_add, Colors.white, 30, "Crea utente", title_rev),
};

/// Builds a BackLayer. A menu with the links to the sections that the user can reach.
/// The menu must be different for operators and supervisors.
/// The menu must show what is the actual page visualized.
///
class MenuLayer extends StatelessWidget {
  String currentViewRoute;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MobileBloc, MobileState>(builder: (context, state) {
      currentViewRoute = context.bloc<MobileBloc>().state.route;
      return Container(
          color: black,
          child: Column(
            children: <Widget>[
              Expanded(
                child: new ListView(
                    physics: new BouncingScrollPhysics(),
                    children: (context.bloc<AuthenticationBloc>().account.supervisor ? menuResponsabile : menuOperatore)
                        .map((route, linkMenu) => _buildMenu(route, linkMenu, context))
                        .values
                        .toList()),
              ),
              Expanded(
                child: Container(
                  child: GestureDetector(
                    onTap: () =>
                        BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut()),
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
    });
  }

  MapEntry<String, Widget> _buildMenu(String route, LinkMenu view, BuildContext context) {
    return new MapEntry(
        route,
        GestureDetector(
          onTap: () => context.bloc<MobileBloc>().add(NavigateEvent(route)),
          child: currentViewRoute == route
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
                                  )))),
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
