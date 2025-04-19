import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String? id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final Map<String, dynamic>? additionalInfo;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.additionalInfo,
    this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      phoneNumber: user.phone,
      displayName: user.userMetadata?['name'],
      photoUrl: user.userMetadata?['avatar_url'],
    );
  }

  factory UserModel.fromSupabaseData(Map<String, dynamic> data, String userId) {
    return UserModel(
      id: userId,
      email: data['email'],
      displayName: data['display_name'],
      photoUrl: data['photo_url'],
      phoneNumber: data['phone_number'],
      additionalInfo: data['additional_info'],
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
      lastLogin:
          data['last_login'] != null
              ? DateTime.parse(data['last_login'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
      'additional_info': additionalInfo,
      'created_at': createdAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
