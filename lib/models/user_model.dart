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
    final userRoles = json['user_roles'] as List<dynamic>?;

    Map<String, dynamic>? roleMap;
    String? roleId;
    String? roleName;

    if (userRoles != null && userRoles.isNotEmpty) {
      final roleItem = userRoles.first;
      roleId = roleItem['role_id']?.toString();
      roleMap = roleItem['roles'];
      roleName = roleMap?['role_name'];
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
