import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum AniProps { width, height, color, opacity, translateY }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {

    final _tween = MovieTween()
      ..tween(AniProps.opacity, Tween(begin: 0.0, end: 1.0),duration:  Duration(milliseconds: 500))
      ..tween(AniProps.translateY, Tween(begin: -30.0, end: 0.0), duration:  Duration(milliseconds: 500),curve:  Curves.easeOut);

    return CustomAnimationBuilder<Movie>(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: _tween.duration,
      control: Control.play,
      tween: _tween,
      child: child,
      builder: (context,  animation, child) => Opacity(
        opacity: animation.get(AniProps.opacity),
        child: Transform.translate(
            offset: Offset(0, animation.get(AniProps.translateY)),
            child: child
        ),
      ),
    );
  }
}