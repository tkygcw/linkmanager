import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/link.dart';
import 'package:linkmanager/object/url.dart';
import 'package:linkmanager/page/url/link/link_detail.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'link_list_view.dart';

class LinkPage extends StatefulWidget {
  final Url url;

  LinkPage({this.url});

  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<LinkPage> {
  String query = '';
  List<Link> links = [];
  bool itemLoad = false;
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
    super.initState();
    connectivity = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        networkConnection = (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi);
      });
    });
    fetchLink();
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
          title: Text(widget.url.label,
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
        body: links.length > 0 && networkConnection
            ? SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.loading) {
                      body = CustomProgressBar();
                    } else if (mode == LoadStatus.failed) {
                      body = Text(
                          '${AppLocalizations.of(context).translate('load_failed')}');
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text(
                          '${AppLocalizations.of(context).translate('release_to_load_more')}');
                    }
                    return Container(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: customListView(),
              )
            : loadingView(),
        floatingActionButton: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.deepPurpleAccent,
          onPressed: () {
            //create new Link
            openLinkDetailPage(null);
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
      if (itemLoad)
        return notFound();
      else
        return CustomProgressBar();
    }
  }

  Widget customListView() {
    return ReorderableListView(
      children: links
          .asMap()
          .map((index, link) => MapEntry(
              index,
              LinkListView(
                link: link,
                key: ValueKey(link.linkId),
                onClick: (Link link, type) {
                  switch (type) {
                    case 'delete':
                      deleteLink(link);
                      break;
                    case 'share':
                      Share.share(link.url, subject: link.label);
                      break;
                    case 'launch':
                      preview(link);
                      break;
                    case 'duplicate':
                      duplicate(link.linkId);
                      break;
                    case 'edit':
                      openLinkDetailPage(link);
                      break;
                  }
                },
              )))
          .values
          .toList(),
      onReorder: _onReorder,
    );
  }

  _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > links.length) newIndex = links.length;
    if (oldIndex < newIndex) newIndex--;

    Link categoryObject = links[oldIndex];
    links.removeAt(oldIndex);
    links.insert(newIndex, categoryObject);

    setState(() {});
    await updateLinkSequence();
  }

  Future updateLinkSequence() async {
    for (int i = 0; i < links.length; i++) {
      links[i].sequence = i + 1;
    }
    Map data = await Domain.callApi(
        Domain.link, {'update_sequence': '1', 'sequence': jsonEncode(links)});

    if (data['status'] == '1') {
      showSnackBar('update_success', 'close');
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
    setState(() {});
  }

  preview(Link link) {
    String previewLink =
        '${Domain.link}?preview=1&channel=${link.type}&url=${link.url}&pre_message=${link.preMessage}';
    launch(previewLink);
  }

  Future duplicate(linkID) async {
    Map data = await Domain.callApi(
        Domain.link, {'duplicate': '1', 'link_id': linkID.toString()});

    if (data['status'] == '1') {
      showSnackBar('duplicate_success', 'close');
      _onRefresh();
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
    setState(() {});
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        itemLoad = false;
        links.clear();
        fetchLink();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  Future fetchLink() async {
    Map data = await Domain.callApi(Domain.link,
        {'read': '1', 'url_id': widget.url.id.toString(), 'query': ''});

    if (data['status'] == '1') {
      List responseJson = data['link'];
      links.addAll(responseJson.map((e) => Link.fromJson(e)));
    } else {
      _refreshController.loadNoData();
    }
    setState(() {
      itemLoad = true;
    });
  }

  /*
  * edit link detail dialog
  * */
  openLinkDetailPage(Link link) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LinkDetailPage(
                link: link,
                urlId: widget.url.id.toString(),
                refresh: () {
                  _onRefresh();
                },
              )),
    );
  }

  /*
  * delete Link
  * */
  deleteLink(Link link) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('delete_request')),
          content: Text(
            AppLocalizations.of(context).translate('delete_link_desc'),
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
                Map data = await Domain.callApi(Domain.link,
                    {'delete': '1', 'link_id': link.linkId.toString()});

                if (data['status'] == '1') {
                  Navigator.of(context).pop();
                  await Future.delayed(Duration(milliseconds: 300));
                  showSnackBar('delete_success', 'close');
                  setState(() {
                    links.remove(link);
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
            ? '${AppLocalizations.of(context).translate('no_link')}'
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
            ? 'drawable/no_link.png'
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
