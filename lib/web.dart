@JS()
library jquery;
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:venturiautospurghi/utils/theme.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';
import 'package:js/js.dart';
import 'package:venturiautospurghi/views/screen_pages/log_in_view.dart';
import 'package:venturiautospurghi/views/screen_pages/reset_auth_account_view.dart';
import 'package:venturiautospurghi/views/web_homepage.dart';
import 'package:venturiautospurghi/views/widgets/splash_screen.dart';
import 'bloc/authentication_bloc/authentication_bloc.dart';
import 'bloc/web_bloc/web_bloc.dart';

@JS()
external void init(bool debug, String idUtente);
external dynamic addResources(dynamic data);

@JS()
external dynamic showAlertJs(dynamic value);
external dynamic consoleLogJs(dynamic value);
/*------------------- jQuery ----------------------------*/
//@JS("jQuery('#calendar').fullCalendar('today').format('dddd D MMMM YYYY')")
//external String today();

@JS()
class jQuery {
  external factory jQuery(String selector);
  external int get length;
  external jQuery html(String content);
  external jQuery hide();
  external jQuery css(CssOptions options);
  external jQuery children();
  external jQuery fullCalendar(String a, String? b);
  external jQuery format(String a);
}

@JS()
@anonymous
class FullCalendar {
  external factory FullCalendar({method, date});
  external dynamic get method;
  external dynamic get date;
}

@JS()
@anonymous
class CssOptions {
  external factory CssOptions({backgroundColor, height, position, width, zIndex, display});
  external dynamic get backgroundColor; // properties based on jQuery api
  external dynamic get height;
  external dynamic get position;
  external dynamic get width;
  external dynamic get zIndex;
  external dynamic get display;
}
/*-------------------------------------------------*/

String jQueryDate() => jQuery('#calendar').fullCalendar('getDate', null).format('MMMM YYYY - ddd D').toString();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.title,
      debugShowCheckedModeBanner: Constants.debug,
      theme: customLightTheme,
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Reset) {
            return ResetAuthAccount(state.autofilledEmail, state.autofilledPhone);
          } else if (state is Unauthenticated) {
            jQuery("#calendar").hide();
            return LogIn();
          } else if (state is Authenticated) {
            var databaseRepository = context.read<AuthenticationBloc>().getDbRepository()!;
            return RepositoryProvider.value(
              value: databaseRepository,
              child: BlocProvider(
                create: (context) =>
                  WebBloc(
                    /*** subscription in [AuthenticationBloc]. When it updates the select make the whole tree rebuild so everything underneath can read the fields. ***/
                    account: context.select((AuthenticationBloc bloc)=> bloc.account!),
                    databaseRepository: databaseRepository)..add(InitAppEvent()),
                child: WebHomepage(),
              ));
          }
          return SplashScreen();
          },
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('it', 'IT'),
      ],
    );
  }
}
