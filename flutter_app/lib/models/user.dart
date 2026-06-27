import 'package:shabakti/core/constants.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePictureUrl;
  final String role;
  final bool isVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePictureUrl,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String? picUrl = json['profile_picture_url'];
    if (picUrl != null && picUrl.startsWith('/')) {
      picUrl = '${AppConstants.baseUrl}$picUrl';
    }
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profilePictureUrl: picUrl,
      role: json['role'],
      isVerified: json['is_verified'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isBeneficiary => role == 'beneficiary';
}
