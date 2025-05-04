class PermissionModel {
  final int id;
  final String name;
  final String description;

  PermissionModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory PermissionModel.fromMap(Map<String, dynamic> map) {
    return PermissionModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }
}
