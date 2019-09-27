//custom import
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/web.dart';


class PlatformUtils {
  PlatformUtils._();

//static void open(String url, {String name}) {
//    html.window.open(url, name);
//}
  static void notify(){}

  static dynamic myApp = MyApp();

  static dynamic gestureDetector({dynamic child, Function onVerticalSwipe, dynamic swipeConfig}){
    throw 'Platform Not Supported';
  }
  static const dynamic simpleSwipeConfig = null;
  static const dynamic Dir = null;
  static dynamic fire = null;
}
