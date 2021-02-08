import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkmanager/object/merchant.dart';
import 'package:linkmanager/object/url.dart';
import 'package:linkmanager/shareWidget/progress_bar.dart';
import 'package:linkmanager/shareWidget/toast.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:linkmanager/utils/sharePreference.dart';

class UrlDialog extends StatefulWidget {
  final Function(String) onClick;
  final Url url;

  UrlDialog({this.url, this.onClick});

  @override
  _UrlDialogState createState() => _UrlDialogState();
}

class _UrlDialogState extends State<UrlDialog> {
  StreamController refreshStream;
  bool isUpdate = false;
  var labelController = TextEditingController();
  var urlController = TextEditingController();
  var domain;
  int urlType = 0;

  bool isActive = true;

  @override
  void initState() {
    // TODO: implement initState
    refreshStream = StreamController();
    getDomain();
    /**
     * create action
     */
    if (widget.url == null) {
      isUpdate = false;
      refreshStream.add('');
      generateUrl();
    }
    /**
     * update action
     */
    else {
      isUpdate = true;
      urlController.text = widget.url.name;
      labelController.text = widget.url.label;
      urlType = widget.url.type;
      isActive = widget.url.status == 0;
      refreshStream.add('display');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: new ThemeData(
        primaryColor: Colors.deepPurple,
      ),
      child: AlertDialog(
          title: new Text(
              '${AppLocalizations.of(context).translate(isUpdate ? 'update_url' : 'create_url')}'),
          actions: <Widget>[
            FlatButton(
              child:
                  Text('${AppLocalizations.of(context).translate('cancel')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                '${AppLocalizations.of(context).translate(isUpdate ? 'update' : 'create')}',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                checkingInput();
              },
            ),
          ],
          content: StreamBuilder(
              stream: refreshStream.stream,
              builder: (context, object) {
                if (object.hasData && object.data.toString().length >= 1) {
                  return mainContent();
                }
                return Container(
                    height: 320, width: 270, child: CustomProgressBar());
              })),
    );
  }

  Widget mainContent() {
    return Container(
      width: 270,
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: labelController,
            maxLines: 1,
            textAlign: TextAlign.start,
            maxLengthEnforced: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('label'),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
              hintText: AppLocalizations.of(context).translate('label_hint'),
              hintStyle: TextStyle(color: Colors.black26),
              border: new OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: new BorderSide(color: Colors.teal)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Text(AppLocalizations.of(context).translate('your_url'),
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.black54, fontSize: 12))),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.deepPurple,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  domain,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                Expanded(
                  child: TextField(
                    controller: urlController,
                    decoration: InputDecoration.collapsed(
                      hintText: '',
                      border: InputBorder.none,
                    ),
                  ),
                  flex: 2,
                ),
                Expanded(
                    child: Container(
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () => generateUrl(),
                  ),
                )),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  AppLocalizations.of(context).translate('url_type'),
                  style: TextStyle(color: Colors.black54),
                )),
                Expanded(
                  flex: 2,
                  child: DropdownButton(
                      value: urlType,
                      isExpanded: true,
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                      items: [
                        DropdownMenuItem(
                          child: Text(AppLocalizations.of(context)
                              .translate('time_based')),
                          value: 0,
                        ),
                        DropdownMenuItem(
                          child: Text(AppLocalizations.of(context)
                              .translate('location_based')),
                          value: 1,
                        )
                      ],
                      onChanged: (value) {
                        urlType = value;
                        refreshStream.add('display');
                      }),
                )
              ],
            ),
          ),
          Text(
            AppLocalizations.of(context).translate('url_type_description'),
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).translate('url_status'),
                style: TextStyle(color: Colors.black87),
              ),
              Switch(
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
                activeTrackColor: Colors.deepPurpleAccent,
                activeColor: Colors.deepPurple,
              ),
            ],
          )
        ],
      ),
    );
  }

  checkingInput() {
    if (labelController.text.isNotEmpty && urlController.text.isNotEmpty) {
      if (!isUpdate)
        createURL();
      else
        updateURL();
    } else
      showToast('missing_input');
  }

  Future generateUrl() async {
    Map data = await Domain.callApi(Domain.url, {
      'read': '1',
      'generate_url': '1',
    });
    if (data['status'] == '1') {
      urlController.text = data['generate_url'];
    } else {}
    refreshStream.add('display');
  }

  createURL() async {
    Map data = await Domain.callApi(Domain.url, {
      'create': '1',
      'merchant_id': '1',
      'name': urlController.text,
      'label': labelController.text,
      'status': isActive ? '0' : '1',
      'type': urlType.toString()
    });

    if (data['status'] == '1') {
      widget.onClick('create_success');
      Navigator.of(context).pop();
    } else if (data['status'] == '3') {
      showToast('url_existed');
    } else
      showToast('something_went_wrong');
  }

  updateURL() async {
    Map data = await Domain.callApi(Domain.url, {
      'update': '1',
      'url_id': widget.url.id.toString(),
      'name': urlController.text,
      'label': labelController.text,
      'status': isActive ? '0' : '1',
      'type': urlType.toString()
    });

    widget.url.status = isActive ? 0 : 1;

    if (data['status'] == '1') {
      widget.onClick('update_success');
      Navigator.of(context).pop();
    } else if (data['status'] == '3') {
      showToast('url_existed');
    } else
      showToast('something_went_wrong');
  }

  getDomain() async {
    this.domain =
        Merchant.fromJson(await SharePreferences().read("merchant")).domain +
            '/';
    setState(() {});
  }

  showToast(message) {
    CustomToast(
      '${AppLocalizations.of(context).translate(message)}',
      context,
    ).show();
  }
}
