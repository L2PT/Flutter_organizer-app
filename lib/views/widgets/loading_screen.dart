import 'package:flutter/material.dart';

/// Rendering page being visualized after the navigation meanwhile
/// the bloc switch from a state from another
/// (Usually {NotLoaded->Loaded->}Filtered->Filtered->{Loaded->}Filtered)
class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}