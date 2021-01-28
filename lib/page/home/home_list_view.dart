import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:linkmanager/object/url.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:share/share.dart';

class HomeListView extends StatelessWidget {
  final Url url;
  final Function(String) showToast;
  final Function(Url) onClick;
  final String domain = 'https://lkmng.com/';

  HomeListView({this.url, this.showToast, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 2,
      child: InkWell(
        onTap: () => null,
        child: Container(
          height: 250,
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(url.label,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold)),
                          Text(getUrl(url.name),
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.blueAccent)),
                        ],
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
                          onPressed: () => this.onClick(url))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                  child: Divider(
                    color: Colors.teal.shade100,
                    thickness: 1.0,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      child: Column(
                        children: [
                          Text(
                            '${AppLocalizations.of(context).translate('link_lick')}',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                          Text(
                            url.linkClickedNum.toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                          Icon(
                            Icons.timeline,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    )),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      child: Column(
                        children: [
                          Text(
                            '${AppLocalizations.of(context).translate('total_link')}',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                          Text(
                            url.linkNum.toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                          Icon(
                            Icons.add_link,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    )),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Text(
                            '${AppLocalizations.of(context).translate('status')}',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                          Text(
                            '0',
                            style: TextStyle(fontSize: 20),
                          ),
                          Icon(
                            Icons.graphic_eq_rounded,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ))
                  ],
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    FlatButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              new ClipboardData(text: getUrl(url.name)));
                          this.showToast('copy_to_clipboard');
                        },
                        icon: Icon(
                          Icons.copy,
                          color: Colors.blue,
                        ),
                        label: Text(
                          AppLocalizations.of(context).translate('copy_link'),
                          style: TextStyle(color: Colors.blue),
                        )),
                    FlatButton.icon(
                        onPressed: () => Share.share(getUrl(url.name)),
                        icon: Icon(
                          Icons.share,
                          color: Colors.green,
                        ),
                        label: Text(
                          AppLocalizations.of(context).translate('share_link'),
                          style: TextStyle(color: Colors.green),
                        )),
                  ],
                )
              ]),
        ),
      ),
    );
  }

  getUrl(String url) {
    return domain + url;
  }
}
