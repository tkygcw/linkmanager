import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.grey[100],
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
      ),
    );
  }
}
