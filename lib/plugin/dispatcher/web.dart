//custom import
import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart' as fs;
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
  static dynamic fire = firestore();

  static dynamic waitFireCollection(collection,{whereCondFirst,whereOp,whereCondSecond}) async {
    var query;
    if(whereOp!=null) {
      query = fire.collection(collection).where(whereCondFirst,whereOp,whereCondSecond);
    }else{
      query = fire.collection(collection);
    }
    var a = await query.get();
    return a.docs;
  }

  static dynamic fireDocument(collection,document) => fire.collection(collection).doc(document).get();

  static dynamic getFireDocumentField(document, field) => document.get(field);


}
