import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/object/report.dart';
import 'package:linkmanager/page/navigationDrawer/navigationDrawer.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/utils/domain.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportPage extends StatefulWidget {
  static const String routeName = '/report';

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Report> channels = [];
  List<Report> browsers = [];
  List<Report> devices = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 2,
        title: Text(AppLocalizations.of(context).translate('report'),
            textAlign: TextAlign.left,
            style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            )),
        actions: <Widget>[],
      ),
      drawer: NavigationDrawer(),
      body: Center(
        child: Container(
            height: 550,
            child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <ChartSeries>[
                  ColumnSeries<Report, String>(
                      dataSource: channels,
                      xValueMapper: (Report sales, _) => sales.label,
                      yValueMapper: (Report sales, _) => sales.data,
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: true))
                ])),
      ),
    );
  }

  Future fetchReport() async {
    Map data =
        await Domain.callApi(Domain.report, {'read': '1', 'url_id': '1'});

    if (data['status'] == '1') {
      List responseJson = data['browser_report'];
      channels.addAll(responseJson.map((e) => Report.fromJson(e)));
      print(channels[0].data);
      print(channels[1].data);
    }
    setState(() {});
  }
}
