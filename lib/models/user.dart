class User {
  final String username;
  final String passwordHash;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  final String? premiumPaymentId;
  final DateTime createdAt;
  final DateTime? lastSyncDate;

  User({
    required this.username,
    required this.passwordHash,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.premiumPaymentId,
    DateTime? createdAt,
    this.lastSyncDate,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiryDate == null) return true; // Lifetime premium
    return DateTime.now().isBefore(premiumExpiryDate!);
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'passwordHash': passwordHash,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'premiumPaymentId': premiumPaymentId,
      'createdAt': createdAt.toIso8601String(),
      'lastSyncDate': lastSyncDate?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      passwordHash: json['passwordHash'],
      isPremium: json['isPremium'] ?? false,
      premiumExpiryDate: json['premiumExpiryDate'] != null
          ? DateTime.parse(json['premiumExpiryDate'])
          : null,
      premiumPaymentId: json['premiumPaymentId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastSyncDate: json['lastSyncDate'] != null
          ? DateTime.parse(json['lastSyncDate'])
          : null,
    );
  }

  User copyWith({
    String? username,
    String? passwordHash,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    String? premiumPaymentId,
    DateTime? createdAt,
    DateTime? lastSyncDate,
  }) {
    return User(
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      premiumPaymentId: premiumPaymentId ?? this.premiumPaymentId,
      createdAt: createdAt ?? this.createdAt,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
    );
  }
} 