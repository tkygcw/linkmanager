import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/branch.dart';
import 'package:linkmanager/object/channel.dart';
import 'package:linkmanager/object/link.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/object/url.dart';
import 'package:linkmanager/page/url/link/day_picker.dart';
import 'package:linkmanager/page/url/link/time_picker.dart';
import 'package:linkmanager/shareWidget/not_found.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';

import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';
import 'package:smart_select/smart_select.dart';
import 'package:url_launcher/url_launcher.dart';

//testing
class LinkDetailPage extends StatefulWidget {
  final Link link;
  final Url url;
  final Function refresh;

  LinkDetailPage({this.link, this.url, this.refresh});

  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<LinkDetailPage> {
  final key = new GlobalKey<ScaffoldState>();
  List<Channel> channel = [];
  String channelLabel = 'WhatsApp';
  Channel selectedChannel;

  var labelController = TextEditingController();
  var url = TextEditingController();
  var preMessage = TextEditingController();

  /*
     * network checking purpose
     * */
  StreamSubscription<ConnectivityResult> connectivity;
  bool networkConnection = true;
  String type = 'WhatsApp';
  int allowDayTime;
  List workingDay = [0, 0, 0, 0, 0, 0, 0];
  List<String> workingTime = [];

  int allowBranch;
  List<int> selectedBranch = [];
  List<Branch> branch = [];

  @override
  void initState() {
    super.initState();
    getPreData();
    connectivity = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        networkConnection = (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi);

        fetchChannel();
        fetchBranch();
      });
    });
    if (widget.link != null) {
      //channel
      channelLabel = widget.link.type;
      url.text = widget.link.url;
      preMessage.text = widget.link.preMessage;
      labelController.text = widget.link.label;
      workingDay = widget.link.workingDay;
      workingTime = widget.link.workingTime;
      selectedBranch = widget.link.branch;
    }
    fetchChannel();
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
          title: Text(
              AppLocalizations.of(context).translate(
                  widget.link == null ? 'new_channel' : 'edit_channel'),
              textAlign: TextAlign.center,
              style: GoogleFonts.aBeeZee(
                textStyle: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )),
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.launch,
                color: Colors.blueGrey,
              ),
              label: Text(
                AppLocalizations.of(context).translate('preview'),
                style: TextStyle(fontSize: 14),
              ),
              onPressed: () {
                checkingInput('preview');
              },
            )
          ],
        ),
        body: networkConnection
            ? Theme(
                data: new ThemeData(
                  primaryColor: Colors.deepPurple,
                ),
                child: mainContent())
            : notFound());
  }

  Widget mainContent() {
    return channel.length > 0
        ? SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: labelController,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    maxLengthEnforced: true,
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context).translate('label'),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle:
                          TextStyle(fontSize: 20, color: Colors.blueGrey),
                      hintText:
                          AppLocalizations.of(context).translate('label_hint'),
                      hintStyle: TextStyle(color: Colors.black26, fontSize: 15),
                      border: new OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('select_channel'),
                            style: TextStyle(fontSize: 15),
                          )),
                      Expanded(
                        flex: 3,
                        child: DropdownButton(
                            value: channelLabel,
                            isExpanded: true,
                            style:
                                TextStyle(fontSize: 15, color: Colors.black87),
                            items: [
                              for (int i = 0; i < channel.length; i++)
                                DropdownMenuItem(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Image.network(
                                          Domain.iconPath + channel[i].icon,
                                          height: 25,
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            channel[i].channel,
                                            textAlign: TextAlign.left,
                                          ))
                                    ],
                                  ),
                                  value: channel[i].channel,
                                )
                            ],
                            onChanged: (channel) async {
                              channelLabel = channel;
                              selectedChannel = await getSelectChannel();
                              //clear data if change channel
                              if (widget.link != null) {
                                if (channelLabel != widget.link.type) {
                                  url.clear();
                                  preMessage.clear();
                                } else {
                                  url.text = widget.link.url;
                                  preMessage.text = widget.link.preMessage;
                                }
                              }
                              setState(() {});
                            }),
                      )
                    ],
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('channel_description'),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: inputLayout(),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Visibility(
                      visible: allowDayTime == 1, child: expansionView()),
                  SizedBox(
                    height: allowDayTime == 1 ? 30 : 0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: RaisedButton(
                      elevation: 5,
                      onPressed: () {
                        checkingInput(null);
                      },
                      child: Text(
                        '${AppLocalizations.of(context).translate(widget.link == null ? 'create_channel' : 'update_channel')}',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Visibility(
                    visible: widget.link != null,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: OutlineButton(
                        onPressed: () {
                          deleteLink(widget.link);
                        },
                        child: Text(
                          '${AppLocalizations.of(context).translate('delete_channel')}',
                          style: TextStyle(color: Colors.red),
                        ),
                        borderSide: BorderSide(width: 1, color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : CustomProgressBar();
  }

  Future<Channel> getSelectChannel() async {
    for (int i = 0; i < channel.length; i++) {
      if (channel[i].channel == channelLabel) {
        return channel[i];
      }
    }
    return Channel();
  }

  Widget inputLayout() {
    return Column(
      children: [
        TextField(
          controller: url,
          keyboardType: selectedChannel.inputType,
          maxLines: 1,
          textAlign: TextAlign.start,
          maxLengthEnforced: true,
          decoration: InputDecoration(
            labelText: selectedChannel.label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(fontSize: 20, color: Colors.blueGrey),
            hintText: selectedChannel.hint,
            hintStyle: TextStyle(color: Colors.black26, fontSize: 15),
            border: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: new BorderSide(color: Colors.teal)),
          ),
        ),
        Visibility(
          visible: selectedChannel.labelMessage != '',
          child: SizedBox(
            height: 15,
          ),
        ),
        Visibility(
          visible: selectedChannel.labelMessage != '',
          child: TextField(
            controller: preMessage,
            minLines: 2,
            maxLines: 3,
            maxLength: 100,
            textAlign: TextAlign.start,
            maxLengthEnforced: true,
            decoration: InputDecoration(
              labelText: selectedChannel.labelMessage,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(fontSize: 20, color: Colors.blueGrey),
              hintText: selectedChannel.messageHint,
              hintStyle: TextStyle(color: Colors.black26, fontSize: 15),
              border: new OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: new BorderSide(color: Colors.teal)),
            ),
          ),
        ),
      ],
    );
  }

  Widget expansionView() {
    return Card(
      elevation: 1,
      child: Theme(
        data: ThemeData.light().copyWith(
            accentColor: Colors.blueAccent,
            unselectedWidgetColor: Colors.black26),
        child: ExpansionTile(
          leading: Icon(Icons.settings),
          title: Text(
            AppLocalizations.of(context).translate('advance_setting'),
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            if (widget.url.type == 1) branchWidget(),
            if (widget.url.type == 1)
              SizedBox(
                height: 30,
              ),
            dateTimeLayout()
          ],
        ),
      ),
    );
  }

  Widget dateTimeLayout() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('working_day'),
            style: TextStyle(fontSize: 15),
          ),
          Text(
            AppLocalizations.of(context).translate('working_day_description'),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(
            height: 10,
          ),
          DayPickers(
              workingDays:
                  widget.link == null ? workingDay : widget.link.workingDay),
          SizedBox(
            height: 30,
          ),
          Text(
            AppLocalizations.of(context).translate('working_time'),
            style: TextStyle(fontSize: 15),
          ),
          Text(
            AppLocalizations.of(context).translate('working_time_description'),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          TimePickers(
              workingTimes: workingTime,
              onChanges: (List time) {
                workingTime = time;
              }),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  Widget branchWidget() {
    /// usage example
    return SmartSelect<int>.multiple(
      title: AppLocalizations.of(context).translate('select_branch'),
      value: selectedBranch,
      choiceItems: S2Choice.listFrom<int, Branch>(
        source: branch,
        value: (index, item) => item.branchId,
        title: (index, item) => item.name,
      ),
      onChange: (state) {
        setState(() => selectedBranch = state.value);
      },
      modalTitle: AppLocalizations.of(context).translate('branch'),
      modalType: S2ModalType.bottomSheet,
      modalConfirm: true,
      modalHeaderStyle: S2ModalHeaderStyle(centerTitle: true),
      tileBuilder: (context, state) {
        return S2Tile.fromState(
          state,
          title: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text:
                        AppLocalizations.of(context).translate('select_branch'),
                    style: TextStyle(fontSize: 15, color: Colors.black)),
                TextSpan(text: '\n'),
                TextSpan(
                  text: AppLocalizations.of(context)
                      .translate('select_branch_description'),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          isTwoLine: false,
          value: state.valueDisplay,
          onTap: state.showModal,
          hideValue: true,
          body: S2TileChips(
            chipLength: state.valueObject.length,
            chipLabelBuilder: (context, i) {
              return Text(state.valueObject[i].title);
            },
            chipOnDelete: (i) {
              print(state.valueObject[i]);
              setState(() => selectedBranch.remove(state.valueObject[i].value));
            },
            chipColor: Colors.deepPurple,
            chipBrightness: Brightness.dark,
            chipBorderOpacity: .1,
          ),
        );
      },
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
              child: Text(AppLocalizations.of(context).translate('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('confirm'),
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Map data = await Domain.callApi(Domain.link,
                    {'delete': '1', 'link_id': link.linkId.toString()});

                if (data['status'] == '1') {
                  showSnackBar('delete_success', 'close');
                  widget.refresh();

                  await Future.delayed(Duration(milliseconds: 500));
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else
                  showSnackBar('something_went_wrong', 'close');
              },
            ),
          ],
        );
      },
    );
  }

  preview() {
    String previewLink =
        '${Domain.link}?preview=1&channel=$channelLabel&url=${url.text}&pre_message=${preMessage.text}';
    launch(previewLink);
  }

  Future fetchChannel() async {
    channel.clear();
    Map data = await Domain.callApi(Domain.link, {'read_channel': '1'});
    if (data['status'] == '1') {
      List responseJson = data['channel'];
      channel.addAll(responseJson.map((e) => Channel.fromJson(e)));
    } else if (data['status'] == '4') {
      showSnackBar('something_went_wrong', 'close');
    }
    selectedChannel = await getSelectChannel();
    setState(() {});
  }

  Future fetchBranch() async {
    branch.clear();
    if (allowBranch != 1) return;

    Map data = await Domain.callApi(Domain.branch, {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
              .toString()
    });
    if (data['status'] == '1') {
      List responseJson = data['branch'];
      branch.addAll(responseJson.map((e) => Branch.fromJson(e)));
    } else if (data['status'] == '4') {
      showSnackBar('something_went_wrong', 'close');
    }
    setState(() {});
  }

  checkingInput(String action) {
    if (labelController.text.isNotEmpty && url.text.isNotEmpty) {
      if (action == 'preview')
        preview();
      else {
        if (widget.link == null)
          createChannel();
        else
          updateChannel();
      }
    } else
      showSnackBar('missing_input', 'close');
  }

  Future createChannel() async {
    Map data = await Domain.callApi(Domain.link, {
      'create': '1',
      'working_time': jsonEncode(workingTime),
      'working_day': workingDay.toString(),
      'branch_id': selectedBranch.toString(),
      'url_id': widget.url.id.toString(),
      'label': labelController.text,
      'pre_message': preMessage.text,
      'url': url.text,
      'type': channelLabel
    });

    if (data['status'] == '1') {
      showSnackBar('create_success', 'close');
      widget.refresh();
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.of(context).pop();
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
  }

  Future updateChannel() async {
    Map data = await Domain.callApi(Domain.link, {
      'update': '1',
      'link_id': widget.link.linkId.toString(),
      'working_time': jsonEncode(workingTime),
      'working_day': workingDay.toString(),
      'branch_id': selectedBranch.toString(),
      'label': labelController.text,
      'pre_message': preMessage.text,
      'url': url.text,
      'type': channelLabel
    });
    if (data['status'] == '1') {
      showSnackBar('update_success', 'close');
      widget.refresh();
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.of(context).pop();
    } else {
      showSnackBar('something_went_wrong', 'close');
    }
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

  getPreData() async {
    this.allowDayTime =
        Merchant.fromJson(await SharePreferences().read("merchant"))
            .allowDateTime;

    this.allowBranch =
        Merchant.fromJson(await SharePreferences().read("merchant"))
            .allowBranch;
    print('Branch: $allowBranch');
    setState(() {
      fetchBranch();
    });
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
