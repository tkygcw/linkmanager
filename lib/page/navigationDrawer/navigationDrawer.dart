import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkmanager/page/navigationDrawer/routes.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          createDrawerHeader(),
          createDrawerBodyItem(
              icon: Icons.home,
              text: AppLocalizations.of(context).translate('home'),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Routes.home)),
          createDrawerBodyItem(
              icon: Icons.location_city,
              text: AppLocalizations.of(context).translate('branch'),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Routes.home)),
          createDrawerBodyItem(
              icon: Icons.analytics,
              text: AppLocalizations.of(context).translate('report'),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Routes.home)),
          Divider(),
          createDrawerBodyItem(
              icon: Icons.info,
              text: AppLocalizations.of(context).translate('about'),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Routes.home)),
          createDrawerBodyItem(
              icon: Icons.settings,
              text: AppLocalizations.of(context).translate('setting'),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Routes.home)),
          ListTile(
            title: Text('App version 1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget createDrawerHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fill,
            image: NetworkImage('')
            )),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text("Welcome to Flutter",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500))),
        ]));
  }

  Widget createDrawerBodyItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
