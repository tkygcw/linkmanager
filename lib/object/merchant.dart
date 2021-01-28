class Merchant {
  int merchantId;
  String name, email, domain, phonePrefix, phone;
  int maxLink, maxUrl, manualGenerate, status;

  Merchant({
    this.merchantId,
    this.name,
    this.email,
    this.domain,
    this.phonePrefix,
    this.phone,
    this.maxLink,
    this.maxUrl,
    this.manualGenerate,
    this.status,
  });

  Merchant.fromJson(Map<String, dynamic> json)
      : merchantId = json['merchant_id'] as int,
        domain = json['domain'],
        name = json['name'],
        email = json['email'],
        phonePrefix = json['phone_prefix'],
        phone = json['phone'],
        maxLink = json['max_link'] as int,
        maxUrl = json['max_url'] as int,
        manualGenerate = json['manual_generate'] as int,
        status = json['status'] as int;

  Map<String, dynamic> toJson() => {
        'merchant_id': merchantId,
        'domain': domain,
        'name': name,
        'email': email,
        'phonePrefix': phonePrefix,
        'phone': phone,
        'maxLink': maxLink,
        'maxUrl': maxUrl,
        'manualGenerate': manualGenerate,
        'status': status,
      };

}
