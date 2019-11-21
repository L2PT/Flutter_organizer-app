import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/models/user.dart';

abstract class PlatformUtils {
  PlatformUtils._();

/* Example
  static void open(String url, {String name}) {
    throw 'Platform Not Supported';
  }
*/

  static const String platform = null;
  static const dynamic myApp = null;

  static dynamic gestureDetector(
      {dynamic child, Function onVerticalSwipe, dynamic swipeConfig}) {
    throw 'Platform Not Supported';
  }

  static const dynamic simpleSwipeConfig = null;
  static dynamic file(path) => null;

  static const dynamic Dir = null;
  static const dynamic fire = null;
  static const dynamic storage = null;

  static dynamic download(url,filename) => null;
  static void initDownloader() => null;

  static dynamic filePicker() => null;

  static dynamic multiFilePicker() => null;

  static dynamic fireDocuments(collection, {whereCondFirst, whereOp, whereCondSecond}) async => null;

  static dynamic customCollectionGroup(categories) => null;

  static List documents(querySnapshot) => null;

  static dynamic setDocument(collection, documentId, data) => null;

  static dynamic updateDocument(collection, documentId, data) => null;

  static dynamic fireDocument(collection, documentId) => null;

  static dynamic extractFieldFromDocument(field, document) => null;

  static dynamic navigator(context, content) => null;

  static dynamic onErrorMessage(msg) => null;

  static Event EventFromMap(id, color, json) => null;

  static Account AccountFromMap(id, json) => null;

}