import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/page/navigationDrawer/routes.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomNavigationDrawer extends StatefulWidget {
  @override
  _CustomNavigationDrawerState createState() => _CustomNavigationDrawerState();
}

class _CustomNavigationDrawerState extends State<CustomNavigationDrawer> {
  Merchant merchant;
  String expiredDate;
  String _platformVersion = 'Default';
  StreamController controller = StreamController();
  var logo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMerchantData();
    getVersionNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          createDrawerHeader(),
          createDrawerBodyItem(
              icon: Icons.home,
              text: AppLocalizations.of(context).translate('home'),
              onTap: () => Navigator.pushReplacementNamed(context, Routes.home)),
          createDrawerBodyItem(
              icon: Icons.location_city,
              text: AppLocalizations.of(context).translate('branch'),
              onTap: () => Navigator.pushReplacementNamed(context, Routes.branch)),
          createDrawerBodyItem(
              icon: Icons.analytics,
              text: AppLocalizations.of(context).translate('report'),
              onTap: () => Navigator.pushReplacementNamed(context, Routes.report)),
          createDrawerBodyItem(
              icon: Icons.qr_code,
              text: AppLocalizations.of(context).translate('qr_code'),
              onTap: () => Navigator.pushReplacementNamed(context, Routes.qRCode)),
          Divider(),
          createDrawerBodyItem(
              icon: Icons.info,
              text: AppLocalizations.of(context).translate('about'),
              onTap: () => Navigator.pushReplacementNamed(context, Routes.about)),
          createDrawerBodyItem(
              icon: Icons.settings,
              text: AppLocalizations.of(context).translate('setting'),
              onTap: () => Navigator.pushReplacementNamed(context, Routes.setting)),
          waterMark()
        ],
      ),
    );
  }

  Widget waterMark() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: InkWell(
            onTap: () => launchUrl(Uri.parse('https://www.channelsoft.com.my')),
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

  void getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    setState(() {
      _platformVersion = version;
    });
  }

  Widget createDrawerHeader() {
    return Container(
        height: 250,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topLeft,
          colors: <Color>[Colors.purple, Colors.deepPurpleAccent],
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
                stream: controller.stream,
                builder: (context, object) {
                  if (object.data == 'display') {
                    return Column(
                      children: [
                        logo != null
                            ? Container(
                                height: 70,
                                decoration: new BoxDecoration(shape: BoxShape.circle, image: new DecorationImage(image: MemoryImage(logo))))
                            : Container(
                                height: 70,
                                child: Image.asset('drawable/white-logo.png'),
                              ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          merchant != null ? merchant.name : '',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          merchant != null ? merchant.email : '',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.white70),
                            children: <TextSpan>[
                              TextSpan(text: AppLocalizations.of(context).translate('expired_date'), style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: expiredDate != null ? ' ${setExpiredDate(expiredDate)}' : ''),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return CustomProgressBar(
                    color: Colors.white70,
                  );
                }),
          ],
        ));
  }

  getMerchantData() async {
    /*
    * fetch logo
    * */
    Map logoData = await Domain.callApi(Domain.merchant, {
      'logo': '1',
      'merchant_id': Merchant.fromJson(await SharePreferences().read("merchant")).merchantId.toString(),
    });

    if (logoData['status'] == '1') {
      if (logoData['logo'][0]['logo'] != '') logo = base64Decode(base64Data(logoData['logo'][0]['logo']));
    }

    merchant = Merchant.fromJson(await SharePreferences().read("merchant"));
    expiredDate = await SharePreferences().read('expired_date');
    controller.add('display');
  }

  base64Data(String data) {
    switch (data.length % 4) {
      case 1:
        break;
      case 2:
        data = data + "==";
        break;
      case 3:
        data = data + "=";
        break;
    }
    return data;
  }

  String setExpiredDate(date) {
    final dateFormat = DateFormat("dd/MM/yyyy");
    try {
      DateTime todayDate = DateTime.parse(date);
      return dateFormat.format(todayDate);
    } on Exception {
      return '';
    }
  }

  Widget createDrawerBodyItem({IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.black45,
          ),
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
