class Report {
  String label;
  int data;

  Report({this.label, this.data});

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(label: json['label'] as String, data: json['data'] as int);
  }
}
