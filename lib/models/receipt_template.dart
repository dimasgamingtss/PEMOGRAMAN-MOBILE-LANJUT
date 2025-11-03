class ReceiptTemplate {
  final String storeName;
  final String description;
  final String address;
  final String phone;
  final String footer1;
  final String footer2;

  ReceiptTemplate({
    required this.storeName,
    required this.description,
    required this.address,
    required this.phone,
    required this.footer1,
    required this.footer2,
  });

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'description': description,
        'address': address,
        'phone': phone,
        'footer1': footer1,
        'footer2': footer2,
      };

  factory ReceiptTemplate.fromJson(Map<String, dynamic> json) => ReceiptTemplate(
        storeName: json['storeName'] ?? '',
        description: json['description'] ?? '',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
        footer1: json['footer1'] ?? '',
        footer2: json['footer2'] ?? '',
      );

  ReceiptTemplate copyWith({
    String? storeName,
    String? description,
    String? address,
    String? phone,
    String? footer1,
    String? footer2,
  }) {
    return ReceiptTemplate(
      storeName: storeName ?? this.storeName,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      footer1: footer1 ?? this.footer1,
      footer2: footer2 ?? this.footer2,
    );
  }
} 