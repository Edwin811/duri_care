class PermissionModel {
  final String id;
  final String name;
  final String description;

  PermissionModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory PermissionModel.fromMap(Map<String, dynamic> map) {
    return PermissionModel(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }
}
