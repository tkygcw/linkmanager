import 'package:toast/toast.dart';

class CustomToast {
  final String message;
  final int duration;
  final int gravity;

  const CustomToast(this.message, {required this.duration, required this.gravity});

  show() {
    Toast.show(message, duration: duration, gravity: gravity);
  }
}
