import 'package:flutter/material.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';


class CustomSnackBar {
  final String message;

  const CustomSnackBar({
    @required this.message,
  });

  static show(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0.0,
        //behavior: SnackBarBehavior.floating,
        content: Text(message),
        duration: new Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(1.0), topRight: Radius.circular(1.0)),
        ),
        //backgroundColor: Colors.redAccent,
        action: SnackBarAction(
          textColor: Color(0xFFFAF2FB),
          label: '${AppLocalizations.of(context).translate('close')}',
          onPressed: () {},
        ),
      ),
    );
  }
}