class Merchant {
  int merchantId;
  String name,
      email,
      domain,
      phonePrefix,
      phone,
      title,
      description,
      logo,
      backgroundColor;

  int maxLink, maxUrl, manualGenerate, allowDateTime, allowBranch, status;

  Merchant(
      {required this.merchantId,
      required this.name,
      required this.email,
      required this.domain,
      required this.phonePrefix,
      required this.phone,
      required this.title,
      required this.description,
      required this.backgroundColor,
      required this.logo,
      required this.maxLink,
      required this.maxUrl,
      required this.manualGenerate,
      required this.status,
      required this.allowDateTime,
      required this.allowBranch});

  Merchant.fromJson(Map<String, dynamic> json)
      : merchantId = json['merchant_id'] as int,
        domain = json['domain'] ?? '',
        name = json['name'] ?? '',
        email = json['email'] ?? '',
        phonePrefix = json['phone_prefix'] ?? '',
        phone = json['phone'] ?? '',
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        backgroundColor = json['background_color'] ?? '',
        logo = json['logo'] ?? '',
        maxLink = json['max_link'] as int? ?? 0,
        maxUrl = json['max_url'] as int? ?? 0,
        allowDateTime = json['allow_date_time'] as int? ?? 0,
        allowBranch = json['allow_branch'] as int? ?? 0,
        manualGenerate = json['manual_generate'] as int? ?? 0,
        status = json['status'] as int? ?? 0;

  Map<String, dynamic> toJson() => {
        'merchant_id': merchantId,
        'domain': domain,
        'name': name,
        'email': email,
        'phone_prefix': phonePrefix,
        'phone': phone,
        'max_link': maxLink,
        'max_url': maxUrl,
        'allow_date_time': allowDateTime,
        'allow_branch': allowBranch,
        'manual_generate': manualGenerate,
        'status': status,
      };
}
