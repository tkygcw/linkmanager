import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';

class TimePickers extends StatefulWidget {
  final List<String> workingTimes;
  final Function(List<String>) onChanges;

  TimePickers({required this.workingTimes, required this.onChanges});

  @override
  _TimePickersState createState() => _TimePickersState();
}

class _TimePickersState extends State<TimePickers> {
  List<String> workingTime = [];

  @override
  void initState() {
    workingTime = widget.workingTimes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: workingTime.length,
            itemBuilder: (BuildContext context, int i) {
              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(AppLocalizations.of(context)!.translate('from_time')),
                      TextButton(
                        onPressed: () {
                          showTimePicker_(DateTime.now(), i, true);
                        },
                        child: Text(
                          getTime(workingTime[i], true) == ''
                              ? AppLocalizations.of(context)!.translate('label_from_time')
                              : getTime(workingTime[i], true),
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(AppLocalizations.of(context)!.translate('to_time')),
                      TextButton(
                        onPressed: () {
                          showTimePicker_(DateTime.now(), i, false);
                        },
                        child: Text(
                          getTime(workingTime[i], true) == ''
                              ? AppLocalizations.of(context)!.translate('label_to_time')
                              : getTime(workingTime[i], false),
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            workingTime.removeAt(i);
                            widget.onChanges(workingTime);
                            setState(() {});
                          })
                    ],
                  ),
                ),
              );
            }),
        SizedBox(
          width: double.infinity,
          height: 50.0,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(width: 1, color: Colors.deepPurpleAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            onPressed: () {
              workingTime.add("00:00 - 23:59");
              widget.onChanges(workingTime);
              setState(() {});
            },
            icon: Icon(
              Icons.add,
              color: Colors.deepPurpleAccent,
            ),
            label: Text(
              '${AppLocalizations.of(context)!.translate('add_time')}',
              style: TextStyle(color: Colors.deepPurpleAccent),
            ),
          ),
        ),
      ],
    ));
  }

  getTime(range, bool startDate) {
    try {
      List<String> time = range.split('-');
      if (startDate)
        return time[0].trim();
      else
        return time[1].trim();
    } catch (e) {
      print('error: $e');
    }
  }

  showTimePicker_(DateTime date, int position, bool startDate) async {
    String timeStr = getTime(workingTime[position], startDate);
    DateTime currentTime = DateFormat("HH:mm").parse(timeStr);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentTime.hour, minute: currentTime.minute),
    );
    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setNewRange(formatted, position, startDate);
      widget.onChanges(workingTime);
      setState(() {});
    }
  }

  setNewRange(selectTime, int position, bool isStartDate) {
    try {
      List<String> time = workingTime[position].split('-');
      if (time.length == 2) {
        if (isStartDate) {
          workingTime[position] = selectTime + '-' + time[1];
        } else {
          workingTime[position] = time[0] + '-' + selectTime;
        }
      }
    } catch (e) {
      print('condition 5');
    }
  }
}
