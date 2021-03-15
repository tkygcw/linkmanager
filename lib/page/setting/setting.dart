import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/page/setting/language_setting.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linkmanager/utils/sharePreference.dart';
import 'package:linkmanager/page/loading.dart';
import 'package:linkmanager/page/setting/profile.dart';
import 'package:linkmanager/page/setting/change_password.dart';

class SettingPage extends StatefulWidget {
  static const String routeName = '/setting';

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final key = new GlobalKey<ScaffoldState>();
  String _platformVersion = 'Default';

  /*
     * network checking purpose
     * */
  StreamSubscription<ConnectivityResult> connectivity;
  bool networkConnection = true;

  @override
  void initState() {
    super.initState();
    //network detector
    connectivity = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        networkConnection = (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi);
      });
    });
    getVersionNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          centerTitle: false,
          elevation: 2,
          title: Text(AppLocalizations.of(context).translate('setting'),
              textAlign: TextAlign.left,
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )),
          actions: <Widget>[],
        ),
        drawer: NavigationDrawer(),
        body: mainContent());
  }

  Widget mainContent() {
    return Theme(
      data: new ThemeData(
        primaryColor: Colors.purple,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('account_setting'),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            SizedBox(
              height: 10,
            ),
            Card(
              elevation: 2,
              child: ListTile(
                onTap: () => openPage('profile'),
                title: Text(AppLocalizations.of(context).translate('profile')),
                leading: Icon(
                  Icons.person_outline,
                  color: Colors.deepPurpleAccent,
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                tileColor: Colors.white,
              ),
            ),
            Card(
              elevation: 2,
              child: ListTile(
                onTap: () => openPage('password'),
                title: Text(
                    AppLocalizations.of(context).translate('change_password')),
                leading: Icon(
                  Icons.lock_outline,
                  color: Colors.blue,
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                tileColor: Colors.white,
              ),
            ),
            Card(
              elevation: 2,
              child: ListTile(
                onTap: () => openPage('language'),
                title:
                    Text(AppLocalizations.of(context).translate('language')),
                leading: Icon(
                  Icons.language,
                  color: Colors.green,
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                tileColor: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              AppLocalizations.of(context).translate('other'),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            SizedBox(
              height: 10,
            ),
            Card(
              elevation: 2,
              child: ListTile(
                onTap: showLogOutDialog,
                title: Text(AppLocalizations.of(context).translate('log_out'),
                    style: TextStyle(color: Colors.red)),
                leading: Icon(
                  Icons.login_outlined,
                  color: Colors.redAccent,
                ),
                trailing:
                    Icon(Icons.keyboard_arrow_right, color: Colors.redAccent),
                tileColor: Colors.white,
              ),
            ),
            waterMark()
          ],
        ),
      ),
    );
  }

  openPage(page) {
    if (page != 'language')
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          if (page == 'profile')
            return ProfilePage();
          else
            return ChangePasswordPage();
        }),
      );
    else
      showLanguageDialog();
  }

  Future<void> showLanguageDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return LanguageDialog();
      },
    );
  }

  void getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    setState(() {
      _platformVersion = version;
    });
  }

  Widget waterMark() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: InkWell(
            onTap: () => launch('https://www.channelsoft.com.my'),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey, fontSize: 11),
                children: <TextSpan>[
                  TextSpan(text: 'Version $_platformVersion'),
                  TextSpan(text: '\n'),
                  TextSpan(
                    text: 'Powered By CHANNEL SOFT PLT',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showLogOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              '${AppLocalizations.of(context).translate('sign_out_request')}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    '${AppLocalizations.of(context).translate('sign_out_message')}'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child:
                  Text('${AppLocalizations.of(context).translate('cancel')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                '${AppLocalizations.of(context).translate('confirm')}',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                logOut();
              },
            ),
          ],
        );
      },
    );
  }

  logOut() async {
    SharePreferences().clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LoadingPage()),
        ModalRoute.withName('/'));
  }

  Widget notFound() {
    if (!networkConnection)
      return NotFound(
          title:
              '${AppLocalizations.of(context).translate('no_network_found')}',
          description:
              '${AppLocalizations.of(context).translate('no_network_found_description')}',
          showButton: true,
          refresh: () {
            setState(() {});
          },
          button: '${AppLocalizations.of(context).translate('retry')}',
          drawable: 'drawable/no_signal.png');
    else
      return CustomProgressBar();
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
