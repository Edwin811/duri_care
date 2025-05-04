class UserRoleModel {
  final int id;
  final String userId;
  final int roleId;

  UserRoleModel({
    required this.id,
    required this.userId,
    required this.roleId,
  });

  factory UserRoleModel.fromMap(Map<String, dynamic> map) {
    return UserRoleModel(
      id: map['id'],
      userId: map['user_id'],
      roleId: map['role_id'],
    );
  }
}
