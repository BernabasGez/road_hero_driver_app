class VehicleModel {
  final int id;
  final String make;
  final String model;
  final String plateNumber;
  final int year;

  VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.plateNumber,
    required this.year,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // 1. Extract Make Name (Handles the nested {id: 6, name: Honda})
    String makeName = "Unknown";
    if (json['make'] is Map) {
      makeName = json['make']['name'] ?? "Unknown";
    } else if (json['make'] is String) {
      makeName = json['make'];
    }

    // 2. Extract Model Name (Handles the nested {id: 1, name: Corolla})
    String modelName = "";
    if (json['model'] is Map) {
      modelName = json['model']['name'] ?? "";
    } else if (json['model'] is String) {
      modelName = json['model'];
    }

    return VehicleModel(
      id: json['id'] ?? 0,
      make: makeName,
      model: modelName,
      plateNumber: json['plate_number'] ?? '',
      year: json['year'] ?? 2020,
    );
  }
}
