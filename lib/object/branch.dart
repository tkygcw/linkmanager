class Branch {
  int branchId, sequence;
  String name;

  Branch({this.name, this.branchId, this.sequence});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
        branchId: json['branch_id'] as int,
        name: json['name'] as String,
        sequence: json['sequence'] as int);
  }

  Map toJson() => {'branch_id': branchId, 'sequence': sequence};
}
