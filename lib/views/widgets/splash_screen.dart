import 'package:flutter/material.dart';
import 'package:venturiautospurghi/utils/theme.dart';


/// Rendering page being visualized before the login page
class SplashScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: logo),
    );
  }

  const SplashScreen();
}
