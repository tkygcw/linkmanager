import 'dart:async';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/object/url.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/page/navigationDrawer/routes.dart';
import 'package:linkmanager/page/qrcode/qrcodePage.dart';
import 'package:linkmanager/page/report/report.dart';
import 'package:linkmanager/page/url/url_dialog.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'home_list_view_v2.dart';
import 'link/link.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';

  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<HomePage> {
  int itemPerPage = 8, currentPage = 1;
  bool itemFinish = false;
  String domain = '';
  String query = '';
  int maxUrl = 0;

  List<Url> urls = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final ScrollController listScrollController = ScrollController();

  final key = new GlobalKey<ScaffoldState>();

  /*flutter pub run flutter_launcher_icons:main
     * network checking purpose
     * */
  StreamSubscription<ConnectivityResult> connectivity;
  bool networkConnection = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreData();
    connectivity = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        networkConnection = (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi);
      });
    });
    fetchUrl();
  }

  // Be sure to cancel subscription after you are done
  @override
  dispose() {
    super.dispose();
    connectivity.cancel();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.white70));

    return Scaffold(
        key: key,
        appBar: AppBar(
          centerTitle: true,
          elevation: 2,
          title: Text(AppLocalizations.of(context).translate('home'),
              textAlign: TextAlign.center,
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              )),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.analytics,
                color: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.report);
                // do something
              },
            )
          ],
        ),
        drawer: NavigationDrawer(),
        body: urls.length > 0 && networkConnection
            ? SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text(
                          '${AppLocalizations.of(context).translate('pull_up_load')}');
                    } else if (mode == LoadStatus.loading) {
                      body = CustomProgressBar();
                    } else if (mode == LoadStatus.failed) {
                      body = Text(
                          '${AppLocalizations.of(context).translate('load_failed')}');
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text(
                          '${AppLocalizations.of(context).translate('release_to_load_more')}');
                    } else {
                      body = Text(
                          '${AppLocalizations.of(context).translate('no_more_data')}');
                    }
                    return Container(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: customListView(),
              )
            : loadingView(),
        bottomNavigationBar: urlLimit(),
        floatingActionButton: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.deepPurpleAccent,
          onPressed: () {
            countUrl();
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ));
  }

  Widget loadingView() {
    if (!networkConnection) {
      return notFound();
    } else {
      if (itemFinish)
        return notFound();
      else
        return CustomProgressBar();
    }
  }

  Widget customListView() {
    return ListView.builder(
      controller: listScrollController,
      itemBuilder: (c, i) => HomeListView(
        url: urls[i],
        domain: domain,
        showToast: (message) {
          showSnackBar(message, 'close');
        },
        onClick: (Url url, action) {
          if (action == 'edit')
            openUrlDialog(context, true, url);
          else if (action == 'delete')
            deleteURL(url);
          else if (action == 'report')
            openReportPage(url);
          else if (action == 'qr_code')
            openQrCodeDialog(context, url);
          else
            openLinkPage(url);
        },
      ),
      itemCount: urls.length,
    );
  }

  Widget urlLimit() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        height: 55,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).translate('max_url'),
                  style: TextStyle(fontSize: 14),
                ),
                Text('${urls.length}/$maxUrl')
              ],
            ),
            SizedBox(height: 5),
            LinearPercentIndicator(
              lineHeight: 10.0,
              animationDuration: 1000,
              animation: true,
              percent: calculateProgress(),
              backgroundColor: Colors.grey,
              progressColor: urls.length < maxUrl
                  ? Colors.lightGreenAccent
                  : Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  calculateProgress() {
    if (urls.length > 0 && maxUrl > 0)
      return urls.length / maxUrl > 1 ? 1.0 : urls.length / maxUrl;
    else
      return 0.0;
  }

  getPreData() async {
    this.domain =
        Merchant.fromJson(await SharePreferences().read("merchant")).domain +
            '/';

    this.maxUrl =
        Merchant.fromJson(await SharePreferences().read("merchant")).maxUrl;

    setState(() {});
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        urls.clear();
        currentPage = 1;
        itemFinish = false;
        fetchUrl();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchUrl();
      });
    }
    _refreshController.loadComplete();
  }

  Future fetchUrl() async {
    Map data = await Domain.callApi(Domain.url, {
      'read': '1',
      'merchant_id': '1',
      'query': '$query',
      'page': '$currentPage',
      'itemPerPage': '$itemPerPage'
    });

    if (data['status'] == '1') {
      List responseJson = data['url'];
      urls.addAll(responseJson.map((e) => Url.fromJson(e)));
    } else {
      _refreshController.loadNoData();
      itemFinish = true;
    }
    setState(() {});
  }

  Future countUrl() async {
    Map data = await Domain.callApi(Domain.url, {
      'count_url': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString(),
    });

    if (data['status'] == '1') {
      int currentUrlNo = data['num_link'];
      if (currentUrlNo < maxUrl)
        openUrlDialog(context, false, null);
      else
        showSnackBar('reach_maximum', 'close');
    }
    setState(() {});
  }

  /*
  * edit address dialog
  * */
  openUrlDialog(mainContext, bool isUpdate, Url url) {
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return UrlDialog(
            url: url,
            onClick: (message) async {
              _onRefresh();
              await Future.delayed(Duration(milliseconds: 300));
              showSnackBar(message, 'close');
              setState(() {});
            });
      },
    );
  }

  /*
  * qr code dialog
  * */
  openQrCodeDialog(mainContext, Url url) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QRCodePage(
                url: url,
              )),
    );
  }

  openLinkPage(Url url) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LinkPage(
                url: url,
              )),
    );
  }

  openReportPage(Url url) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReportPage(
                urlID: url.id,
              )),
    );
  }

  /*
  * delete url
  * */
  deleteURL(Url url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('delete_request')),
          content: Text(
            AppLocalizations.of(context).translate('delete_url_desc'),
            style: TextStyle(color: Colors.black87, fontSize: 15),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Map data = await Domain.callApi(
                    Domain.url, {'delete': '1', 'url_id': url.id.toString()});

                if (data['status'] == '1') {
                  Navigator.of(context).pop();
                  await Future.delayed(Duration(milliseconds: 300));
                  showSnackBar('delete_success', 'close');
                  setState(() {
                    urls.remove(url);
                  });
                } else
                  showSnackBar('something_went_wrong', 'close');
              },
            ),
          ],
        );
      },
    );
  }

  Widget notFound() {
    return NotFound(
        title: networkConnection
            ? '${AppLocalizations.of(context).translate('no_url')}'
            : '${AppLocalizations.of(context).translate('no_network_found')}',
        description: networkConnection
            ? '${AppLocalizations.of(context).translate('no_url_description')}'
            : '${AppLocalizations.of(context).translate('no_network_found_description')}',
        showButton: true,
        refresh: () {
          setState(() {});
        },
        button: '${AppLocalizations.of(context).translate('retry')}',
        drawable: networkConnection
            ? 'drawable/no_item.png'
            : 'drawable/no_signal.png');
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
