//custom import for mobile
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:venturiautospurghi/mobile.dart';

abstract class PlatformUtils {
  PlatformUtils._();

  //custom import for mobile
//static void open(String url, {String name}) async {
//    if (await canLaunch(url)) {
//      await launch(url);
//    }
//}

  static dynamic myApp = MyApp();

  static SimpleGestureDetector gestureDetector({dynamic child, Function onVerticalSwipe, SimpleSwipeConfig swipeConfig}){
    return SimpleGestureDetector(
      child: child,
      onVerticalSwipe: onVerticalSwipe,
      swipeConfig: swipeConfig,
    );
  }
  static const dynamic simpleSwipeConfig = SimpleSwipeConfig(
    verticalThreshold: 25.0,
    swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
  );
  static const dynamic Dir = SwipeDirection.up;

}
