class RoleModel {
  final String id;
  final String name;
  final String? description;

  RoleModel({required this.id, required this.name, this.description});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'].toString(),
      name: json['role_name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'role_name': name, 'description': description};
  }
}
