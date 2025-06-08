// import 'package:duri_care/models/permission_model.dart';
// import 'package:duri_care/models/role_model.dart';

// class RolePermissionModel {
//   final String id;
//   final String roleId;
//   final String permissionId;
//   final RoleModel? role;
//   final PermissionModel? permission;

//   RolePermissionModel({
//     required this.id,
//     required this.roleId,
//     required this.permissionId,
//     this.role,
//     this.permission,
//   });

//   factory RolePermissionModel.fromMap(Map<String, dynamic> map) {
//     return RolePermissionModel(
//       id: map['id'].toString(),
//       roleId: map['role_id'].toString(),
//       permissionId: map['permission_id'].toString(),
//       role: map['role'] != null ? RoleModel.fromJson(map['role']) : null,
//       permission:
//           map['permission'] != null
//               ? PermissionModel.fromMap(map['permission'])
//               : null,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {'id': id, 'role_id': roleId, 'permission_id': permissionId};
//   }
// }
