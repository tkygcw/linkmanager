import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/object/url.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/page/report/channelGraph.dart';
import 'package:linkmanager/page/report/deviceGraph.dart';
import 'package:linkmanager/page/report/locationGraph.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';

import 'broswerGraph.dart';

class ReportPage extends StatefulWidget {
  static const String routeName = '/report';

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final key = new GlobalKey<ScaffoldState>();
  int urlID = 1;
  String domain;
  List<Url> urlList = [];

  /*
     * network checking purpose
     * */
  StreamSubscription<ConnectivityResult> connectivity;
  bool networkConnection = true;

  @override
  void initState() {
    super.initState();
    connectivity = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        networkConnection = (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi);
        fetchURL();
      });
    });
    fetchURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          centerTitle: false,
          elevation: 2,
          title: Text(AppLocalizations.of(context).translate('report'),
              textAlign: TextAlign.left,
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              )),
          actions: <Widget>[],
        ),
        drawer: NavigationDrawer(),
        body: mainContent());
  }

  Widget mainContent() {
    return networkConnection
        ? SingleChildScrollView(
            child: Column(
              children: [
                urlSelection(),
                SizedBox(
                  height: 10,
                ),
                ChannelGraph(urlID: urlID.toString()),
                SizedBox(
                  height: 20,
                ),
                BrowserGraph(urlID: urlID.toString()),
                SizedBox(
                  height: 20,
                ),
                DeviceGraph(
                  urlID: urlID.toString(),
                ),
                SizedBox(
                  height: 20,
                ),
                LocationGraph(
                  urlID: urlID.toString(),
                ),
              ],
            ),
          )
        : notFound();
  }

  Widget urlSelection() {
    return Card(
        margin: EdgeInsets.all(5),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context).translate('select_url'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              Container(
                height: 50,
                child: DropdownButton(
                    value: urlID,
                    isExpanded: true,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                    items: [
                      for (int i = 0; i < urlList.length; i++)
                        DropdownMenuItem(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  urlList[i].label,
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      '$domain ${urlList[i].name}',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.blue),
                                    ))
                              ],
                            ),
                          ),
                          value: urlList[i].id,
                        )
                    ],
                    onChanged: (url) async {
                      setState(() {
                        urlID = url;
                      });
                    }),
              ),
            ],
          ),
        ));
  }

  Future fetchURL() async {
    urlList.clear();
    this.domain =
        Merchant.fromJson(await SharePreferences().read("merchant")).domain;

    Map data = await Domain.callApi(Domain.url, {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString()
    });
    if (data['status'] == '1') {
      print(data['url']);
      List responseJson = data['url'];
      urlList.addAll(responseJson.map((e) => Url.fromJson(e)));
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
    setState(() {});
  }

  Widget notFound() {
    return NotFound(
        title: '${AppLocalizations.of(context).translate('no_network_found')}',
        description:
            '${AppLocalizations.of(context).translate('no_network_found_description')}',
        showButton: true,
        refresh: () {
          setState(() {});
        },
        button: '${AppLocalizations.of(context).translate('retry')}',
        drawable: 'drawable/no_signal.png');
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
