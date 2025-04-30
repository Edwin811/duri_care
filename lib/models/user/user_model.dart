import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String? id;
  final String? email;
  final String? fullname;
  final String? profileUrl;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    this.id,
    this.email,
    this.fullname,
    this.profileUrl,
    this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullname: user.userMetadata?['fullname'],
      profileUrl: user.userMetadata?['profile_url'],
    );
  }

  factory UserModel.fromSupabaseData(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
      fullname: data['fullname'],
      profileUrl: data['profile_url'],
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
      'id': id,
      'email': email,
      'fullname': fullname,
      'profile_url': profileUrl,
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
      fullname: displayName ?? fullname,
      profileUrl: photoUrl ?? profileUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
