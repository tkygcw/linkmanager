import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/object/url.dart';
import 'package:linkmanager/page/home/home_list_view.dart';
import 'package:linkmanager/page/home/url_dialog.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/shareWidget/snack_bar.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  List<Url> urls = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final ScrollController listScrollController = ScrollController();

  final key = new GlobalKey<ScaffoldState>();

  /*
     * network checking purpose
     * */
  StreamSubscription<ConnectivityResult> connectivity;
  bool networkConnection = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDomain();
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
                Icons.share,
                color: Colors.deepPurple,
              ),
              onPressed: () {
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
        floatingActionButton: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.deepPurpleAccent,
          onPressed: () {
            //create new url
            openUrlDialog(context, false, null);
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
          else
            deleteURL(url);
        },
      ),
      itemCount: urls.length,
    );
  }

  getDomain() async {
    this.domain = Merchant.fromJson(await SharePreferences().read("merchant")).domain + '/';
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
            onClick: (message) {
              showSnackBar(message, 'close');
            });
      },
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
