import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';

  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<HomePage> {
  int itemPerPage = 8, currentPage = 1;
  bool itemFinish = false;

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];

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
          elevation: 0,
          title: Text(AppLocalizations.of(context).translate('home'),
              textAlign: TextAlign.center,
              style: GoogleFonts.cantoraOne(
                textStyle: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              )),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.orange,
              ),
              onPressed: () {
                // do something
              },
            )
          ],
        ),
        drawer: NavigationDrawer(),
        body: SmartRefresher(
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
        ));
  }

  Widget customListView() {
    return ListView.builder(
      controller: listScrollController,
      itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
      itemExtent: 100.0,
      itemCount: items.length,
    );
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
//        list.clear();
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
    Map data = await Domain().callApi();
    print(data);
    setState(() {
      if (data['status'] == '1') {
        List responseJson = data['product'];
      } else {
        _refreshController.loadNoData();
        itemFinish = true;
      }
    });
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
        drawable: 'drawable/no_wifi.png');
  }

  showSnackBar(message, button) {
    key.currentState.showSnackBar(new SnackBar(
        content: new Text(message),
        action: SnackBarAction(
          label: button,
          onPressed: () {
            setState(() {});
            // Some code to undo the change.
          },
        )));
  }
}
