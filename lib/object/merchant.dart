class Merchant {
  int merchantId;
  String name, email, domain, phonePrefix, phone, title, description;
  int maxLink, maxUrl, manualGenerate, allowDateTime, allowBranch, status;

  Merchant(
      {this.merchantId,
      this.name,
      this.email,
      this.domain,
      this.phonePrefix,
      this.phone,
      this.title,
      this.description,
      this.maxLink,
      this.maxUrl,
      this.manualGenerate,
      this.status,
      this.allowDateTime,
      this.allowBranch});

  Merchant.fromJson(Map<String, dynamic> json)
      : merchantId = json['merchant_id'] as int,
        domain = json['domain'],
        name = json['name'],
        email = json['email'],
        phonePrefix = json['phone_prefix'],
        phone = json['phone'],
        title = json['title'],
        description = json['description'],
        maxLink = json['max_link'] as int,
        maxUrl = json['max_url'] as int,
        allowDateTime = json['allow_date_time'] as int,
        allowBranch = json['allow_branch'] as int,
        manualGenerate = json['manual_generate'] as int,
        status = json['status'] as int;

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
