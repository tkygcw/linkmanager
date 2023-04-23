import 'dart:async';

import 'package:flutter/material.dart';
import 'package:linkmanager/object/report.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChannelGraph extends StatefulWidget {
  final String urlID, startDate, endDate;

  ChannelGraph({this.urlID, this.startDate, this.endDate});

  @override
  _ChannelGraphState createState() => _ChannelGraphState();
}

class _ChannelGraphState extends State<ChannelGraph> {
  List<Report> channels = [];

  // ignore: close_sinks
  StreamController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = StreamController();
  }

  @override
  Widget build(BuildContext context) {
    fetchReport();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                getText('channels'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              mainContent()
            ],
          ),
        ),
      ),
    );
  }

  Widget mainContent() {
    return Container(
      height: 350,
      width: double.infinity,
      child: StreamBuilder(
          stream: controller.stream,
          builder: (context, object) {
            if (object.data == 'display') {
              return Center(
                child: Container(
                    child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(),
                        legend: Legend(isVisible: true, position: LegendPosition.bottom),
                        series: <ChartSeries>[
                      ColumnSeries<Report, String>(
                          name: getText('channel'),
                          dataSource: channels,
                          xValueMapper: (Report sales, _) => sales.label,
                          yValueMapper: (Report sales, _) => sales.data,
                          pointColorMapper: (Report sales, _) => Colors.deepPurple,
                          // Enable data label
                          dataLabelSettings: DataLabelSettings(isVisible: true))
                    ])),
              );
            } else if (object.data == 'no_data')
              return Center(
                  child: Text(
                getText('no_record_found'),
                style: TextStyle(color: Colors.grey),
              ));
            return Container(height: 100, alignment: Alignment.center, child: CircularProgressIndicator());
          }),
    );
  }

  Future fetchReport() async {
    print(widget.startDate);
    print(widget.endDate);
    controller.add('');
    await Future.delayed(Duration(milliseconds: 500));

    channels.clear();
    Map data = await Domain.callApi(
        Domain.report, {'channel_report': '1', 'url_id': widget.urlID, 'from_date': widget.startDate, 'to_date': widget.endDate});

    print(data);
    if (data['status'] == '1') {
      List responseJson = data['channel_report'];
      channels.addAll(responseJson.map((e) => Report.fromJson(e)));
      controller.add('display');
    } else
      controller.add('no_data');
  }

  getText(text) {
    return AppLocalizations.of(context).translate(text);
  }
}
