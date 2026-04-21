class VehicleModel {
  final int id;
  final int? makeId;
  final int? modelId;
  final String? makeName;
  final String? modelName;
  final String plateNumber;
  final int? year;

  const VehicleModel({
    required this.id,
    this.makeId,
    this.modelId,
    this.makeName,
    this.modelName,
    required this.plateNumber,
    this.year,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      makeId: json['make_id'] ?? json['make']?['id'],
      modelId: json['model_id'] ?? json['model']?['id'],
      makeName: json['make']?['name'] ?? json['make_name'],
      modelName: json['model']?['name'] ?? json['model_name'],
      plateNumber: json['plate_number'] ?? '',
      year: json['year'],
    );
  }

  String get displayName {
    final parts = <String>[];
    if (makeName != null) parts.add(makeName!);
    if (modelName != null) parts.add(modelName!);
    if (parts.isEmpty) return plateNumber;
    return parts.join(' ');
  }
}
