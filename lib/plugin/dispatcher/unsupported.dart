import 'package:venturiautospurghi/models/event.dart';

abstract class PlatformUtils {
  PlatformUtils._();

/* Example
  static void open(String url, {String name}) {
    throw 'Platform Not Supported';
  }
*/

  static const dynamic myApp = null;

  static dynamic gestureDetector(
      {dynamic child, Function onVerticalSwipe, dynamic swipeConfig}) {
    throw 'Platform Not Supported';
  }

  static const dynamic simpleSwipeConfig = null;
  static const dynamic Dir = null;
  static const dynamic fire = null;

  static dynamic waitFireCollection(collection,
      {whereCondFirst, whereOp, whereCondSecond}) async => null;

  static dynamic fireDocument(collection, document) => null;

  static dynamic extractFieldFromDocument(field, document) => null;

  static dynamic navigator(context, content) => null;

  static Event EventFromMap(id, color, json) => null;

}