class Url {
  String label, name, createdAt;

  int id, status, type, linkClickedNum, linkNum;

  Url(
      {required this.id,
      required this.name,
      required this.label,
      required this.type,
      required this.createdAt,
      required this.status,
      required this.linkClickedNum,
      required this.linkNum});

  factory Url.fromJson(Map<String, dynamic> json) {
    return Url(
        id: json['url_id'] as int,
        label: json['label'] as String,
        name: json['name'] as String,
        type: json['type'] as int,
        createdAt: json['created_at'] as String,
        status: json['status'] as int,
        linkClickedNum: json['link_click_num'] as int,
        linkNum: json['link_num'] as int);
  }

  @override
  String toString() {
    return '${this.label}';
  }
}
