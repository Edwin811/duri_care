class UserPermissionModel {
  final int id;
  final String userId;
  final int permissionId;

  UserPermissionModel({
    required this.id,
    required this.userId,
    required this.permissionId,
  });

  factory UserPermissionModel.fromMap(Map<String, dynamic> map) {
    return UserPermissionModel(
      id: map['id'],
      userId: map['user_id'],
      permissionId: map['permission_id'],
    );
  }
}
