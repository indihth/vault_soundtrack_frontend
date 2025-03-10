class UserProfile {
  // final String id;
  final String displayName;
  final String isAdmin;
  final String product;
  final DateTime joinedAt;

  UserProfile({
    // required this.id,
    required this.displayName,
    required this.isAdmin,
    required this.product,
    required this.joinedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      // id: json['id'] as String,
      displayName: json['displayName'] ?? '',
      isAdmin: json['isAdmin'] ?? '',
      product: json['product'] ?? '',
      joinedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'displayName': displayName,
      'isAdmin': isAdmin,
      'product': product,
      'updated_at': joinedAt.toIso8601String(),
    };
  }
}
