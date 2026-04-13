import 'dart:convert';

class Link {
  int linkId, sequence, linkClick;
  String label, type, url, preMessage, icon, createAt;
  List<String> workingTime;
  List<int> workingDay;
  List<int> branch;

  Link(
      {required this.linkId,
      required this.sequence,
      required this.label,
      required this.type,
      required this.url,
      required this.icon,
      required this.preMessage,
      required this.workingTime,
      required this.workingDay,
      required this.branch,
      required this.createAt,
      required this.linkClick});

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
        workingDay: bindWorkingDay(json['working_day']),
        branch: bindWorkingDay(json['branch_id']), createAt: '');
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
