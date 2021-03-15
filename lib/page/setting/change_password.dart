import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  Merchant merchant;
  final key = new GlobalKey<ScaffoldState>();

  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool hideNewPassword = true;
  bool hideConfirmPassword = true;
  bool hideCurrentPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          centerTitle: false,
          elevation: 2,
          title: Text(AppLocalizations.of(context).translate('change_password'),
              textAlign: TextAlign.left,
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )),
          actions: <Widget>[],
        ),
        body: mainContent());
  }

  Widget mainContent() {
    return Theme(
      data: new ThemeData(
        primaryColor: Colors.purple,
      ),
      child: Card(
          margin: EdgeInsets.all(15),
          elevation: 5,
          child: Container(
              height: 400,
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('change_password'),
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    AppLocalizations.of(context)
                        .translate('change_password_description'),
                    style: TextStyle(color: Colors.black26, fontSize: 14),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                      keyboardType: TextInputType.text,
                      obscureText: hideCurrentPassword,
                      controller: currentPassword,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_open),
                        labelText:
                            '${AppLocalizations.of(context).translate('current_password')}',
                        labelStyle:
                            TextStyle(fontSize: 14, color: Colors.blueGrey),
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal)),
                        suffixIcon: IconButton(
                          icon: Icon(hideCurrentPassword
                              ? Icons.remove_red_eye
                              : Icons.close),
                          onPressed: () {
                            setState(() {
                              hideCurrentPassword = !hideCurrentPassword;
                            });
                          },
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                      keyboardType: TextInputType.text,
                      obscureText: hideNewPassword,
                      controller: newPassword,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_open),
                        labelText:
                            '${AppLocalizations.of(context).translate('new_password')}',
                        labelStyle:
                            TextStyle(fontSize: 14, color: Colors.blueGrey),
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal)),
                        suffixIcon: IconButton(
                          icon: Icon(hideNewPassword
                              ? Icons.remove_red_eye
                              : Icons.close),
                          onPressed: () {
                            setState(() {
                              hideNewPassword = !hideNewPassword;
                            });
                          },
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                      keyboardType: TextInputType.text,
                      obscureText: hideConfirmPassword,
                      controller: confirmPassword,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_open),
                        labelText:
                            '${AppLocalizations.of(context).translate('confirm_password')}',
                        labelStyle:
                            TextStyle(fontSize: 14, color: Colors.blueGrey),
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal)),
                        suffixIcon: IconButton(
                          icon: Icon(hideConfirmPassword
                              ? Icons.remove_red_eye
                              : Icons.close),
                          onPressed: () {
                            setState(() {
                              hideConfirmPassword = !hideConfirmPassword;
                            });
                          },
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: RaisedButton.icon(
                      onPressed: () {
                        if (newPassword.text == confirmPassword.text)
                          updatePassword();
                        else
                          showSnackBar('password_not_match', 'close');
                      },
                      icon: Icon(
                        Icons.security,
                        color: Colors.white,
                      ),
                      color: Colors.deepPurpleAccent,
                      label: Text(
                        '${AppLocalizations.of(context).translate('update_password')}',
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                ],
              ))),
    );
  }

  Future updatePassword() async {
    Map data = await Domain.callApi(Domain.register, {
      'update': '1',
      'current_password': currentPassword.text,
      'new_password': newPassword.text,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString()
    });
    if (data['status'] == '1') {
      showSnackBar('update_success', 'close');
      currentPassword.clear();
      newPassword.clear();
      confirmPassword.clear();
      setState(() {});
    } else if (data['status'] == '3') {
      showSnackBar('current_pass_not_match', 'close');
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
  }

  showSnackBar(preMessage, button) {
    key.currentState.showSnackBar(new SnackBar(
        content: new Text(AppLocalizations.of(context).translate(preMessage)),
        action: SnackBarAction(
          label: AppLocalizations.of(context).translate(button),
          onPressed: () {
            setState(() {});
            // Some code to undo the change.
          },
        )));
  }
}
