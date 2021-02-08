import 'dart:convert';

class Link {
  int linkId, sequence, linkClick;
  String label, type, url, preMessage, icon, createAt;
  List<String> workingTime;
  List<int> workingDay;

  Link(
      {this.linkId,
      this.sequence,
      this.label,
      this.type,
      this.url,
      this.icon,
      this.preMessage,
      this.workingTime,
      this.workingDay,
      this.createAt,
      this.linkClick});

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
        linkId: json['link_id'] as int,
        sequence: json['sequence'] as int,
        linkClick: json['link_click'] as int,
        label: json['label'],
        url: json['url'],
        icon: json['icon'],
        type: json['type'],
        preMessage: json['pre_message'],
        workingTime: bindWorkingTime(json['working_time']),
        workingDay: bindWorkingDay(json['working_day']));
  }

  static List<String> bindWorkingTime(json) {
    try {
      return List.from(jsonDecode(json));
    } catch (e) {
      return [];
    }
  }

  static List<int> bindWorkingDay(json) {
    try {
      return List.from(jsonDecode(json));
    } catch (e) {
      return [];
    }
  }

  Map toJson() => {'link_id': linkId, 'sequence': sequence};
}
