import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String? id;
  final String? email;
  final String? fullname;
  final String? profileUrl;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  UserModel({
    this.id,
    this.email,
    this.fullname,
    this.profileUrl,
    this.createdAt,
    this.lastSignInAt,
  });

  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullname: user.userMetadata?['fullname'],
      profileUrl: user.userMetadata?['profile_image'],
    );
  }

  factory UserModel.fromSupabaseData(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
      fullname: data['fullname'],
      profileUrl: data['profile_image'],
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : null,
      lastSignInAt:
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
      'profile_image': profileUrl,
      'created_at': createdAt?.toIso8601String(),
      'last_login': lastSignInAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullname,
    String? profileUrl,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      profileUrl: profileUrl ?? this.profileUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }
}
