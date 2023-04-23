import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/branch.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';
import 'package:refreshable_reorderable_list/refreshable_reorderable_list.dart';

class BranchPage extends StatefulWidget {
  static const String routeName = '/branch';

  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<BranchPage> {
  List<Branch> branches = [];
  bool itemLoad = false;

  final ScrollController listScrollController = ScrollController();
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController branchName = TextEditingController();

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
    fetchBranch();
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
          title: Text(AppLocalizations.of(context).translate('branch'),
              textAlign: TextAlign.center,
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.deepPurple,
              ),
              onPressed: () {
                _onRefresh();
              },
            )
          ],
        ),
        drawer: CustomNavigationDrawer(),
        body: branches.length > 0 && networkConnection
            ? mainContent()
            : loadingView(),
        floatingActionButton: FloatingActionButton(
          elevation: 5,
          backgroundColor: Colors.deepPurpleAccent,
          onPressed: () {
            //create new Branch
            branchDetailDialog(null);
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

  Widget mainContent() {
    return RefreshableReorderableListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: branches
          .asMap()
          .map((index, link) => MapEntry(index, listView(link)))
          .values
          .toList(),
      onReorder: _onReorder,
    );
  }

  _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > branches.length) newIndex = branches.length;
    if (oldIndex < newIndex) newIndex--;

    Branch categoryObject = branches[oldIndex];
    branches.removeAt(oldIndex);
    branches.insert(newIndex, categoryObject);

    setState(() {});
    await updateLinkSequence();
  }

  Future updateLinkSequence() async {
    for (int i = 0; i < branches.length; i++) {
      branches[i].sequence = i + 1;
    }
    Map data = await Domain.callApi(Domain.branch,
        {'update_sequence': '1', 'sequence': jsonEncode(branches)});

    if (data['status'] == '1') {
      showSnackBar('update_success', 'close');
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
    setState(() {});
  }

  Widget listView(Branch branch) {
    return Card(
        key: ValueKey(branch.branchId.toString()),
        elevation: 2,
        child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Icon(
                    Icons.unfold_more,
                    size: 35,
                    color: Colors.black26,
                  ),
                ),
                Expanded(
                    child: Text(
                  branch.name,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  maxLines: 1,
                )),
                IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blueGrey,
                    ),
                    onPressed: () => branchDetailDialog(branch)),
                IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => deleteBranch(branch))
              ],
            )));
  }

  _onRefresh() async {
    setState(() {
      itemLoad = false;
      branches.clear();
      fetchBranch();
    });
  }

  Future fetchBranch() async {
    Map data = await Domain.callApi(Domain.branch, {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString()
    });
    if (data['status'] == '1') {
      List responseJson = data['branch'];
      branches.addAll(responseJson.map((e) => Branch.fromJson(e)));
    }
    setState(() {
      itemLoad = true;
    });
  }

  /*
  * delete Branch
  * */
  deleteBranch(Branch branch) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('delete_request')),
          content: Text(
            AppLocalizations.of(context).translate('delete_branch_description'),
            style: TextStyle(color: Colors.black87, fontSize: 15),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Map data = await Domain.callApi(Domain.branch,
                    {'delete': '1', 'branch_id': branch.branchId.toString()});
                print(data);
                if (data['status'] == '1') {
                  Navigator.of(context).pop();
                  await Future.delayed(Duration(milliseconds: 300));
                  showSnackBar('delete_success', 'close');
                  setState(() {
                    branches.remove(branch);
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

  /*
  * create n update branch
  * */
  branchDetailDialog(Branch branch) {
    if (branch != null)
      branchName.text = branch.name;
    else
      branchName.clear();
    //show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate(branch == null ? 'create_branch' : 'edit_branch')),
          content: Theme(
            data: new ThemeData(
              primaryColor: Colors.purpleAccent,
              primaryColorDark: Colors.purpleAccent,
            ),
            child: TextField(
              controller: branchName,
              maxLines: 1,
              textAlign: TextAlign.start,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('label'),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
                hintText: 'Branch A',
                hintStyle: TextStyle(color: Colors.black26),
                border: new OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Map data;
                /**
                 * create new branch
                 */
                if (branch == null) {
                  data = await Domain.callApi(Domain.branch, {
                    'create': '1',
                    'merchant_id': Merchant.fromJson(
                            await SharePreferences().read("merchant"))
                        .merchantId
                        .toString(),
                    'name': branchName.text
                  });
                }
                /*
                * update branch
                * */
                else {
                  data = await Domain.callApi(Domain.branch, {
                    'update': '1',
                    'branch_id': branch.branchId.toString(),
                    'name': branchName.text
                  });
                }

                if (data['status'] == '1') {
                  Navigator.of(context).pop();
                  await Future.delayed(Duration(milliseconds: 300));
                  showSnackBar(
                      branch == null ? 'create_success' : 'update_success',
                      'close');

                  setState(() {
                    if (branch == null)
                      _onRefresh();
                    else {
                      branch.name = branchName.text;
                    }
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
            ? '${AppLocalizations.of(context).translate('no_record_found')}'
            : '${AppLocalizations.of(context).translate('no_network_found')}',
        description: networkConnection
            ? '${AppLocalizations.of(context).translate('no_url_description')}'
            : '${AppLocalizations.of(context).translate('no_network_found_description')}',
        showButton: true,
        refresh: () {
          _onRefresh();
        },
        button: '${AppLocalizations.of(context).translate('retry')}',
        drawable: networkConnection
            ? 'drawable/no_branch.png'
            : 'drawable/no_signal.png');
  }

  showSnackBar(message, button) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
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
