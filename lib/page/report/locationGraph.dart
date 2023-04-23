import 'dart:async';

import 'package:flutter/material.dart';
import 'package:linkmanager/object/report.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LocationGraph extends StatefulWidget {
  final String urlID;

  LocationGraph({this.urlID});

  @override
  _LocationGraphState createState() => _LocationGraphState();
}

class _LocationGraphState extends State<LocationGraph> {
  List<Report> locations = [];

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
                getText('locations'),
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
      height: 200,
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
                        legend: Legend(
                            isVisible: true, position: LegendPosition.bottom),
                        series: <ChartSeries>[
                      ColumnSeries<Report, String>(
                          name: getText('device'),
                          dataSource: locations,
                          xValueMapper: (Report sales, _) => sales.label,
                          yValueMapper: (Report sales, _) => sales.data,
                          pointColorMapper: (Report sales, _) =>
                              Colors.deepPurple,
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
            return Container(
                height: 100,
                alignment: Alignment.center,
                child: CircularProgressIndicator());
          }),
    );
  }

  Future fetchReport() async {
    controller.add('');
    await Future.delayed(Duration(milliseconds: 500));

    locations.clear();
    Map data = await Domain.callApi(
        Domain.report, {'location_report': '1', 'url_id': widget.urlID});

    if (data['status'] == '1') {
      List responseJson = data['location_report'];
      locations.addAll(responseJson.map((e) => Report.fromJson(e)));
      controller.add('display');
    } else
      controller.add('no_data');
  }

  getText(text) {
    return AppLocalizations.of(context).translate(text);
  }
}
