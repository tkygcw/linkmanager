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
      id: json['url_id'] ?? 0,
      label: json['label'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 0,
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? 0,
      linkClickedNum: json['link_click_num'] ?? 0,
      linkNum: json['link_num'] ?? 0,
    );
  }

  @override
  String toString() {
    return '${this.label}';
  }
}
