import 'package:toast/toast.dart';

class CustomToast {
  final String message;
  final int duration;
  final int gravity;

  const CustomToast(this.message, {this.duration, this.gravity});

  show() {
    Toast.show(message, duration: duration, gravity: gravity == null ? Toast.bottom : gravity);
  }
}
