import 'package:flutter/material.dart';


/// Rendering page to visualized after the login
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Splash Screen')),
    );
  }
}

/// Rendering page to be sialized after the navigation meanwhile
/// the bloc switch from a state from another
/// (Usually {NotLoaded->Loaded->}Filtered->Filtered->{Loaded->}Filtered)
class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Splash Screen')),
    );
  }
}
