import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';

class DayPickers extends StatefulWidget {
  final List workingDays;

  DayPickers({this.workingDays});

  @override
  _DayPickersState createState() => _DayPickersState();
}

class _DayPickersState extends State<DayPickers> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GridView.builder(
            shrinkWrap: true,
            itemCount: widget.workingDays.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 2),
            itemBuilder: (BuildContext context, int i) {
              return Card(
                elevation: 2,
                child: ListTile(
                  onTap: () {
                    widget.workingDays[i] = widget.workingDays[i] == 0 ? 1 : 0;
                    setState(() {});
                  },
                  tileColor: widget.workingDays[i] == 0 ? Colors.purple : Colors.white,
                  title: Text(
                    '${AppLocalizations.of(context).translate('day${i + 1}')}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color:
                        widget.workingDays[i] == 0 ? Colors.white : Colors.black54),
                  ),
                ),
              );
            }));
  }
}
