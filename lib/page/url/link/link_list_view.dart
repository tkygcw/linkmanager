
import 'package:flutter/material.dart';
import 'package:linkmanager/object/link.dart';
import 'package:linkmanager/object/branch.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';

class LinkListView extends StatelessWidget {
  final Link link;
  final int urlType;
  final List<Branch> branches;
  final Key key;
  final Function(String) showToast;
  final Function(Link, String) onClick;

  LinkListView(
      {this.link, this.urlType, this.branches, this.key, this.showToast, this.onClick})
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
            height: urlType == 1 ? 200 : 175,
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
                                  fontSize: 16, color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 20,
                          color: Colors.black54,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(getWorkingTime(link.workingTime),
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.black54,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(getWorkingDay(link.workingDay),
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: urlType == 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: Colors.black54,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(getBranch(link.branch),
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black87)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: link.sequence == 1,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset:
                                    Offset(1, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(2),
                          child: Text(
                            AppLocalizations.of(context).translate('default'),
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          )),
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

  getWorkingTime(List<String> workingTime) {
    return workingTime.length > 0
        ? workingTime.toString().substring(1, workingTime.toString().length - 1)
        : 'All Time';
  }

  getBranch(List<int> branch) {
    String branchName = '';
    if (branches.length > 0) {
      for (int i = 0; i < branch.length; i++) {
        for (int j = 0; j < branches.length; j++) {
          if (branch[i] == branches[j].branchId) {
            branchName +=
                branches[j].name + (i == branch.length - 1 ? '' : ', ');
          }
        }
      }
    }
    return branchName == ''
        ? 'No branch selected.'
        : branchName;
  }

  getWorkingDay(List<int> workingDay) {
    List<String> weekDay = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    String workDay = '';
    bool workAllDay = true;

    for (int i = 0; i < workingDay.length; i++) {
      if (workingDay[i] == 0) {
        workDay += weekDay[i] + ', ';
        continue;
      }
      if (workAllDay) workAllDay = false;
    }
    return workAllDay
        ? 'All Day'
        : workDay;
  }
}
