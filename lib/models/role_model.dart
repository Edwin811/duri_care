class RoleModel {
  final String id;
  final String name;

  RoleModel({required this.id, required this.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(id: json['id'].toString(), name: json['role_name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'role_name': name};
  }
}
