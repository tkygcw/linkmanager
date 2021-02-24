import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_version/get_version.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  static const String routeName = '/about';

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _platformVersion = 'Unknown';
  String _projectVersion = '';
  String _projectCode = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        elevation: 2,
        title: Text(AppLocalizations.of(context).translate('about'),
            textAlign: TextAlign.center,
            style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            )),
      ),
      drawer: NavigationDrawer(),
      body: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Container(
              height: 10.0,
            ),
            new ListTile(
              leading: new Icon(Icons.info),
              title: Text(AppLocalizations.of(context).translate('name')),
              subtitle: new Text('Link Manager'),
            ),
            new Container(
              height: 10.0,
            ),
            new ListTile(
              leading: new Icon(Icons.info),
              title: Text(AppLocalizations.of(context).translate('running_on')),
              subtitle: new Text(_platformVersion),
            ),
            new Divider(
              height: 20.0,
            ),
            new ListTile(
              leading: new Icon(Icons.info),
              title: Text(AppLocalizations.of(context).translate('version_name')),
              subtitle: new Text(_projectVersion),
            ),
            new Divider(
              height: 20.0,
            ),
            new ListTile(
              leading: new Icon(Icons.info),
              title: Text(AppLocalizations.of(context).translate('version_code')),
              subtitle: new Text(_projectCode),
            ),
            new Divider(
              height: 20.0,
            ),
            new ListTile(
              onTap: () => launch('https://api.whatsapp.com/send?phone=60143157329&text=PmLinkManager'),
              leading: new Icon(Icons.info),
              title: Text(AppLocalizations.of(context).translate('contact_info')),
              subtitle: new Text('www.channelsoft.com.my\nchannelsoftmy@gmail.com\n+6014-315 7329'),
            ),
          ],
        ),
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GetVersion.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    String projectVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      projectVersion = await GetVersion.projectVersion;
    } on PlatformException {
      projectVersion = 'Failed to get project version.';
    }

    String projectCode;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      projectCode = await GetVersion.projectCode;
    } on PlatformException {
      projectCode = 'Failed to get build number.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _projectVersion = projectVersion;
      _projectCode = projectCode;
    });
  }
}
