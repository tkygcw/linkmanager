import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/object/url.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/page/report/channelGraph.dart';
import 'package:linkmanager/page/report/deviceGraph.dart';
import 'package:linkmanager/page/report/monthlyReport.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';

import 'broswerGraph.dart';

class ReportPage extends StatefulWidget {
  static const String routeName = '/report';
  final urlID;

  ReportPage({this.urlID});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final key = new GlobalKey<ScaffoldState>();
  int urlID;
  String domain;
  List<Url> urlList = [];

  List<String> sortingTypes = ['Today', 'Yesterday', 'Last 7 Days', 'One Month'];
  String selectedType = 'Today';

  var fromDate, toDate;
  final selectedDateFormat = DateFormat("yyy-MM-dd");

  /*
     * network checking purpose
     * */
  var connectivity;
  bool networkConnection = true;

  @override
  void initState() {
    super.initState();
    if (widget.urlID != null) this.urlID = widget.urlID;
    //network detector
    connectivity = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        networkConnection = (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi);
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
                textStyle: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 20),
              )),
          actions: <Widget>[],
        ),
        drawer: widget.urlID == null ? CustomNavigationDrawer() : null,
        body: mainContent());
  }

  Widget mainContent() {
    return networkConnection != null
        ? SingleChildScrollView(
            child: Column(
              children: [
                urlSelection(),
                SizedBox(
                  height: 10,
                ),
                ChannelGraph(
                  urlID: urlID.toString(),
                  startDate: fromDate != null ? selectedDateFormat.format(fromDate).toString() : '',
                  endDate: toDate != null ? selectedDateFormat.format(toDate).toString() : '',
                ),
                SizedBox(
                  height: 20,
                ),
                BrowserGraph(
                  urlID: urlID.toString(),
                  startDate: fromDate != null ? selectedDateFormat.format(fromDate).toString() : '',
                  endDate: toDate != null ? selectedDateFormat.format(toDate).toString() : '',
                ),
                SizedBox(
                  height: 20,
                ),
                DeviceGraph(
                  urlID: urlID.toString(),
                  startDate: fromDate != null ? selectedDateFormat.format(fromDate).toString() : '',
                  endDate: toDate != null ? selectedDateFormat.format(toDate).toString() : '',
                ),
                SizedBox(
                  height: 10,
                ),
                MonthlyGraph(urlID: urlID.toString()),
              ],
            ),
          )
        : notFound();
  }

  Widget buttonBar() {
    return Container(
      height: 50,
      child: GridView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: kIsWeb ? 4 : 4,
            childAspectRatio: kIsWeb ? 7 : 2.5,
          ),
          children: List.generate(sortingTypes.length, (index) {
            return InkWell(
              onTap: () {
                setState(() {
                  selectedType = sortingTypes[index];
                  setupDate();
                });
              },
              child: Container(
                  color: selectedType == sortingTypes[index] ? Colors.deepPurple : Colors.white,
                  alignment: Alignment.center,
                  child: Text(
                    sortingTypes[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selectedType == sortingTypes[index] ? Colors.white : Colors.black54,
                        fontSize: kIsWeb ? 16 : 12),
                  )),
            );
          })),
    );
  }

  setupDate() {
    if (selectedType == 'Today') {
      toDate = fromDate = DateTime.now();
    } else if (selectedType == 'Yesterday') {
      var today = DateTime.now();
      toDate = fromDate = DateTime(today.year, today.month, today.day - 1);
    } else if (selectedType == 'Last 7 Days') {
      var today = DateTime.now();
      fromDate = DateTime(today.year, today.month, today.day - 7);
      toDate = DateTime(today.year, today.month, today.day);
    } else {
      var today = DateTime.now();
      fromDate = DateTime(today.year, today.month, 1);
      toDate = DateTime(today.year, today.month, today.day);
    }
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
              Text(
                AppLocalizations.of(context).translate('select_url'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    urlList[i].label,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      '$domain/${urlList[i].name}',
                                      style: TextStyle(fontSize: 14, color: Colors.blue),
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
                        print(urlID);
                      });
                    }),
              ),
              SizedBox(
                width: 10,
              ),
              buttonBar(),
              SizedBox(
                width: 10,
              ),
              sortingLayout()
            ],
          ),
        ));
  }

  Widget sortingLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextButton.icon(
              label: Text(
                fromDate != null ? selectedDateFormat.format(fromDate).toString() : '${AppLocalizations.of(context).translate('from_date')}',
                style: TextStyle(color: Colors.blueGrey, fontSize: 13),
              ),
              icon: Icon(Icons.date_range),
              onPressed: () {
                DatePicker.showDatePicker(context, showTitleActions: true, onChanged: (date) {}, onConfirm: (date) {
                  setState(() {
                    fromDate = date;
                  });
                }, currentTime: fromDate != null ? fromDate : DateTime.now(), locale: LocaleType.zh);
              }),
        ),
        Expanded(
          flex: 2,
          child: TextButton.icon(
              label: Text(
                toDate != null ? selectedDateFormat.format(toDate).toString() : '${AppLocalizations.of(context).translate('to_date')}',
                style: TextStyle(color: Colors.blueGrey, fontSize: 13),
              ),
              icon: Icon(Icons.date_range),
              onPressed: () {
                DatePicker.showDatePicker(context, showTitleActions: true, onChanged: (date) {}, onConfirm: (date) {
                  setState(() {
                    toDate = date;
                  });
                }, currentTime: toDate != null ? toDate : DateTime.now(), locale: LocaleType.zh);
              }),
        ),
      ],
    );
  }

  Future fetchURL() async {
    this.domain = Merchant.fromJson(await SharePreferences().read("merchant")).domain;

    urlList.clear();
    Map data = await Domain.callApi(
        Domain.url, {'read': '1', 'merchant_id': Merchant.fromJson(await SharePreferences().read("merchant")).merchantId.toString()});
    print(data);
    if (data['status'] == '1') {
      List responseJson = data['url'];
      urlList.addAll(responseJson.map((e) => Url.fromJson(e)));
    } else if (data['status'] == '4') {
      showSnackBar('something_went_wrong', 'close');
    }

    setState(() {
      //set default as first url
      if (urlID == null && urlList.length > 0) {
        urlID = urlList[0].id;
      }
    });
  }

  Widget notFound() {
    return NotFound(
        title: networkConnection
            ? '${AppLocalizations.of(context).translate('no_report_found')}'
            : '${AppLocalizations.of(context).translate('no_network_found')}',
        description: networkConnection
            ? '${AppLocalizations.of(context).translate('no_report_found_description')}'
            : '${AppLocalizations.of(context).translate('no_network_found_description')}',
        showButton: true,
        refresh: () async {
          await fetchURL();
          setState(() {});
        },
        button: '${AppLocalizations.of(context).translate('retry')}',
        drawable: networkConnection ? 'drawable/no_report.png' : 'drawable/no_signal.png');
  }

  showSnackBar(preMessage, button) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
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
