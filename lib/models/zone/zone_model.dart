class ZoneModel {
  String? id;
  String? name;
  String? owner_id;
  String? createdAt;
  String? updatedAt;

  ZoneModel({
    this.id,
    this.name,
    this.owner_id,
    this.createdAt,
    this.updatedAt,
  });

  ZoneModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    owner_id = json['onowner_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['owner_id'] = owner_id;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
