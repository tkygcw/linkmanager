import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';
import 'package:package_info/package_info.dart';

import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final key = new GlobalKey<ScaffoldState>();
  var email = TextEditingController();
  var password = TextEditingController();
  String _platformVersion = 'Default';

  FocusNode emailFocusNode, passwordFocusNode;

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.purple
    ));
    return Scaffold(
      key: key,
      body: mainContent(),
    );
  }

  @override
  void initState() {
    super.initState();
    getVersionNumber();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    setState(() {
      _platformVersion = version;
    });
  }

  void _requestFocus(FocusNode focusNode) {
    setState(() {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  Widget mainContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 80, 30, 30),
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.purpleAccent, Colors.deepPurpleAccent],
          )),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset('drawable/white-logo.png' ),
            ),
            flex: 2,
          ),
          Expanded(
            child: body(),
            flex: 6,
          ),
          Expanded(
            child: bottomBar(),
            flex: 1,
          ),
        ],
      ),
    );
  }

  Widget body() {
    return Column(
      children: [
        TextFormField(
          focusNode: emailFocusNode,
          style: TextStyle(color: Colors.white),
          controller: email,
          maxLines: 1,
          textAlign: TextAlign.start,
          maxLengthEnforced: true,
          keyboardType: TextInputType.emailAddress,
          onTap: () => _requestFocus(emailFocusNode),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).translate('email'),
            labelStyle: TextStyle(
              color: emailFocusNode.hasFocus ? Colors.white : Colors.white60,
            ),
            prefixIcon: Icon(
              Icons.email,
              color: emailFocusNode.hasFocus ? Colors.white : Colors.white70,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: emailFocusNode.hasFocus ? Colors.white : Colors.white60,
              ),
              onPressed: () {
                setState(() {
                  email.clear();
                });
              },
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white60),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: password,
          maxLines: 1,
          textAlign: TextAlign.start,
          obscureText: hidePassword,
          maxLengthEnforced: true,
          focusNode: passwordFocusNode,
          onTap: () => _requestFocus(passwordFocusNode),
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).translate('password'),
            prefixIcon: Icon(
              Icons.lock_open,
              color: passwordFocusNode.hasFocus ? Colors.white : Colors.white70,
            ),
            labelStyle: TextStyle(
              color: passwordFocusNode.hasFocus ? Colors.white : Colors.white60,
            ),
            suffixIcon: IconButton(
              icon: hidePassword
                  ? Icon(Icons.remove_red_eye,
                  color: passwordFocusNode.hasFocus
                      ? Colors.white
                      : Colors.white60)
                  : Icon(
                Icons.close,
                color: passwordFocusNode.hasFocus
                    ? Colors.white
                    : Colors.white60,
              ),
              onPressed: () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white60),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          child: TextButton(
              onPressed: () {
                openForgotPassword();
              },
              child: Text(
                AppLocalizations.of(context).translate('forgot_password'),
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.start,
              )),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          width: double.infinity,
          height: 50,
          child: OutlineButton(
            borderSide: BorderSide(width: 1, color: Colors.white),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              AppLocalizations.of(context).translate('login'),
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              inputChecking();
            },
          ),
        ),
      ],
    );
  }

  inputChecking() {
    if (email.text.isNotEmpty && password.text.isNotEmpty) {
      login();
    } else {
      showSnackBar('missing_input', 'close');
    }
  }

  Future login() async {
    Map data = await Domain.callApi(Domain.register,
        {'login': '1', 'email': email.text, 'password': password.text});

    if (data['status'] == '1') {
      await SharePreferences()
          .save('merchant', Merchant(merchantId: data['merchant_id']));

      Navigator.pushReplacementNamed(context, '/');
    } else if (data['status'] == '2') {
      showSnackBar('email_password_not_match', 'close');
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
  }

  void openForgotPassword() {
    print('haha');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPassword(),
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'All Right Reserved By CHANNEL SOFT PLT',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          Text(
            '${AppLocalizations.of(context).translate(
                'version')} $_platformVersion',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  showSnackBar(message, button) {
    key.currentState.showSnackBar(new SnackBar(
        content: new Text(AppLocalizations.of(context).translate(message)),
        action: SnackBarAction(
          label: AppLocalizations.of(context).translate(button),
          onPressed: () {
            setState(() {});
            // Some code to undo the change.
          },
        )));
  }
}
