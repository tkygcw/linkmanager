import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class CustomToast {
  final String message;
  final int duration;
  final int gravity;
  final BuildContext context;

  const CustomToast(this.message, this.context, {this.duration, this.gravity});

  show() {
    Toast.show(message, context, duration: duration, gravity: gravity == null ? Toast.BOTTOM : gravity);
  }
}
