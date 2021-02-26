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
  final Function(Url, String) onClick;
  final String domain;

  HomeListView({this.domain, this.url, this.showToast, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3,
      child: InkWell(
        onTap: () => onClick(url, 'open_link_page'),
        child: Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
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
                      ),
                      dropDown()
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Row(
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
                              url.status == 0 ? 'Active' : 'Deactive',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: url.status == 0
                                      ? Colors.lightGreen
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ))
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget dropDown() {
    return PopupMenuButton(
      offset: Offset(0, 10),
      icon: Icon(
        Icons.menu,
        color: Colors.black26,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: <Widget>[
              Icon(
                Icons.edit,
                color: Colors.grey,
              ),
              SizedBox(
                width: 10,
              ),
              Text(AppLocalizations.of(context).translate('edit')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: <Widget>[
              Icon(
                Icons.launch,
                color: Colors.grey,
              ),
              SizedBox(
                width: 10,
              ),
              Text(AppLocalizations.of(context).translate('copy_link')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: <Widget>[
              Icon(
                Icons.share,
                color: Colors.grey,
              ),
              SizedBox(
                width: 10,
              ),
              Text(AppLocalizations.of(context).translate('share_link')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'preview',
          child: Row(
            children: <Widget>[
              Icon(
                Icons.launch,
                color: Colors.grey,
              ),
              SizedBox(
                width: 10,
              ),
              Text(AppLocalizations.of(context).translate('preview')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: <Widget>[
              Icon(
                Icons.analytics,
                color: Colors.grey,
              ),
              SizedBox(
                width: 10,
              ),
              Text(AppLocalizations.of(context)
                  .translate('report')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: <Widget>[
              Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                AppLocalizations.of(context).translate('delete'),
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'delete':
            this.onClick(url, 'delete');
            break;
          case 'edit':
            this.onClick(url, 'edit');
            break;
          case 'report':
            this.onClick(url, 'report');
            break;
          case 'copy':
            Clipboard.setData(new ClipboardData(text: getUrl(url.name)));
            this.showToast('copy_to_clipboard');
            break;
          case 'share':
            Share.share(getUrl(url.name), subject: url.label);
            break;
          case 'preview':
            Share.share(getUrl(url.name), subject: url.label);
            break;
        }
      },
    );
  }

  getUrl(String url) {
    return domain + url;
  }
}
