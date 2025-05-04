class IrrigationStatusModel {
  final int id;
  final String statusName;

  IrrigationStatusModel({required this.id, required this.statusName});

  factory IrrigationStatusModel.fromMap(Map<String, dynamic> map) {
    return IrrigationStatusModel(
      id: map['id'],
      statusName: map['status_name'],
    );
  }
}
