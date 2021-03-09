import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomProgressBar extends StatelessWidget {
  final Color color;

  CustomProgressBar({this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCube(
        color: color != null ? color : Colors.blueAccent,
        size: 40.0,
      ),
    );
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.grey[100],
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
      ),
    );
  }
}
