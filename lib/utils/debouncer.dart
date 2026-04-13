import 'dart:async';

import 'package:flutter/material.dart';

class DelayTimer {
  final int milliseconds;
  Timer? _timer;

  DelayTimer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();

    _timer = Timer(
      Duration(milliseconds: milliseconds),
      action,
    );
  }
}
