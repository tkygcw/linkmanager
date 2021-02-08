import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:linkmanager/object/link.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';

class LinkListView extends StatelessWidget {
  final Link link;
  final Key key;
  final Function(String) showToast;
  final Function(Link, String) onClick;

  LinkListView({this.link, this.key, this.showToast, this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        key: key,
        margin: EdgeInsets.all(10),
        elevation: 2,
        child: InkWell(
          onTap: () => onClick(link, 'edit'),
          child: Container(
            height: 110,
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
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
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.label,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Image.network(
                          Domain.iconPath + link.icon,
                          height: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(link.url,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                  ],
                )),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          link.linkClick.toString(),
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.remove_red_eye,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                    PopupMenuButton(
                      offset: Offset(0, 10),
                      icon: Icon(
                        Icons.settings,
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
                              Text(AppLocalizations.of(context)
                                  .translate('edit')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.copy,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(AppLocalizations.of(context)
                                  .translate('duplicate')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'launch',
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.launch,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(AppLocalizations.of(context)
                                  .translate('preview')),
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
                              Text(AppLocalizations.of(context)
                                  .translate('share_link')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                AppLocalizations.of(context)
                                    .translate('delete_link'),
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        this.onClick(this.link, value);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
