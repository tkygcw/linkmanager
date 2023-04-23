import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkmanager/shareWidget/snack_bar.dart';
import 'package:linkmanager/shareWidget/toast.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var email = TextEditingController();
  var pac = TextEditingController();

  var newPassword = TextEditingController();
  var confirmPassword = TextEditingController();

  bool hideNewPassword = true;
  bool hideConfirmPassword = true;

  StreamController pageStream;
  String pacNumber;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageStream = StreamController();
    pageStream.add('email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(30, 80, 30, 30),
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
            child: StreamBuilder(
                stream: pageStream.stream,
                builder: (context, object) {
                  if (object.data == 'email') {
                    return enterEmail(context);
                  } else if (object.data == 'pac') {
                    return verifyPac(context);
                  } else
                    return resetPassword(context);
                })),
      ),
    );
  }

  enterEmail(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.backspace,
            color: Colors.lightBlue,
            size: 30,
          ),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Image.asset('drawable/forgot_password_icon.png', height: 200),
                ),
                Text(
                  '${AppLocalizations.of(context).translate('forgot_password')}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  '${AppLocalizations.of(context).translate('forgot_password_description')}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.white,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: email,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: '${AppLocalizations.of(context).translate('email')}',
                      labelStyle: TextStyle(fontSize: 16, color: Colors.blueAccent),
                      hintText: '',
                    ),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 1, color: Colors.blueAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Colors.orange),
                    onPressed: () => sendPac(context),
                    child: Text(
                      '${AppLocalizations.of(context).translate('send_pac')}',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ))
      ],
    );
  }

  verifyPac(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.backspace,
            color: Colors.lightBlue,
            size: 30,
          ),
          onPressed: () => pageStream.add('email'),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Image.asset('drawable/email_icon.png', height: 200),
                ),
                Text(
                  '${AppLocalizations.of(context).translate('email_verification')}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  '${AppLocalizations.of(context).translate('email_verification_description')}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.white,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                    ],
                    controller: pac,
                    textAlign: TextAlign.start,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.verified_user),
                      labelText: '${AppLocalizations.of(context).translate('pac_no')}',
                      labelStyle: TextStyle(fontSize: 16, color: Colors.blueAccent),
                      hintText: '',
                    ),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "${AppLocalizations.of(context).translate('click_to_resend')}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  textAlign: TextAlign.start,
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 1, color: Colors.blueAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Colors.orange),
                    onPressed: () => checkPac(context),
                    child: Text(
                      '${AppLocalizations.of(context).translate('verify_email')}',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ))
      ],
    );
  }

  resetPassword(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.backspace,
            color: Colors.lightBlue,
            size: 30,
          ),
          onPressed: () => pageStream.add('pac'),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Image.asset('drawable/change_password_icon.png', height: 200),
                ),
                Text(
                  '${AppLocalizations.of(context).translate('reset_password')}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  '${AppLocalizations.of(context).translate('reset_password_description')}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.blueAccent,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: newPassword,
                    obscureText: hideNewPassword,
                    textAlign: TextAlign.start,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: '${AppLocalizations.of(context).translate('new_password')}',
                      labelStyle: TextStyle(fontSize: 16, color: Colors.blueAccent),
                      suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              hideNewPassword = !hideNewPassword;
                            });
                          }),
                    ),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Theme(
                  data: new ThemeData(
                    primaryColor: Colors.blueAccent,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    obscureText: hideConfirmPassword,
                    controller: confirmPassword,
                    textAlign: TextAlign.start,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.verified_user),
                      labelText: '${AppLocalizations.of(context).translate('confirmation_password')}',
                      labelStyle: TextStyle(fontSize: 16, color: Colors.blueAccent),
                      hintText: '',
                      suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              hideConfirmPassword = !hideConfirmPassword;
                            });
                          }),
                    ),
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      side: BorderSide(width: 1, color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => updatePassword(context),
                    child: Text(
                      '${AppLocalizations.of(context).translate('update_password')}',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ))
      ],
    );
  }

  /*
  * send pac via email
  * */
  sendPac(context) async {
    CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('verify')}');

    pacNumber = (new Random().nextInt(900000) + 100000).toString();

    Map data = await Domain.callApi(Domain.register, {'forgot_password': '1', 'email': email.text, 'pac': pacNumber});

    if (data['status'] == '1') {
      CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('pac_sent')}');
      pageStream.add('pac');
    } else
      CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('invalid_email')}');
  }

  checkPac(context) {
    if (pac.text == pacNumber) {
      CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('verify_success')}');
      pageStream.add('reset');
    } else
      CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('invalid_pac_number')}');
  }

  updatePassword(context) async {
    if (newPassword.text.length > 0) {
      if (newPassword.text == confirmPassword.text) {
        Map data = await Domain.callApi(Domain.register, {'forgot_password': '1', 'new_password': newPassword.text, 'email': email.text});

        if (data['status'] == '1') {
          CustomToast(
            '${AppLocalizations.of(context).translate('password_update_success')}',
          ).show();
          Navigator.pushReplacementNamed(context, '/login');
        } else
          CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('something_went_wrong')}');
      } else
        CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('password_not_match')}');
    } else
      CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('all_field_required')}');
  }
}
