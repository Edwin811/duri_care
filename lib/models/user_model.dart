class UserModel {
  final String id;
  final String? email;
  final DateTime? lastSignInAt;
  final String? fullname;
  final String? profileUrl;
  final String? roleId;
  final String? roleName;

  UserModel({
    required this.id,
    this.email,
    this.lastSignInAt,
    this.fullname,
    this.profileUrl,
    this.roleId,
    this.roleName,
  });

  factory UserModel.empty() {
    return UserModel(id: '');
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email'],
      lastSignInAt: map['last_sign_in_at'] != null
          ? DateTime.tryParse(map['last_sign_in_at'])
          : null,
      fullname: map['fullname'],
      profileUrl: map['profile_image'],
      roleId: map['role_id']?.toString(),
      roleName: map['role_name'],
    );
  }

  factory UserModel.fromCombinedJson(
    Map<String, dynamic> auth,
    Map<String, dynamic> user,
  ) {
    return UserModel(
      id: auth['id'],
      email: auth['email'],
      lastSignInAt:
          auth['last_sign_in_at'] != null
              ? DateTime.tryParse(auth['last_sign_in_at'])
              : null,
      fullname: user['fullname'],
      profileUrl: user['profile_image'],
      roleId: user['role_id']?.toString(),
      roleName: user['role']?['role_name'],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? roleName = json['role_name'];
    String? roleId = json['role_id']?.toString();

    if (roleName == null) {
      final userRoles = json['user_roles'] as List<dynamic>?;

      if (userRoles != null && userRoles.isNotEmpty) {
        final roleItem = userRoles.first;
        roleId = roleItem['role_id']?.toString();
        final roleMap = roleItem['roles'];
        roleName = roleMap?['role_name'];
      }
    }

    return UserModel(
      id: json['id'].toString(),
      email: json['email'],
      fullname: json['fullname'],
      profileUrl: json['profile_image'],
      roleId: roleId,
      roleName: roleName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
      'fullname': fullname,
      'profile_image': profileUrl,
      'role_id': roleId,
      'role_name': roleName,
    };
  }
}
