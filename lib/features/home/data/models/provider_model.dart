class ProviderModel {
  final int id;
  final String businessName;
  final double rating;
  final double distanceKm;

  ProviderModel({
    required this.id,
    required this.businessName,
    required this.rating,
    required this.distanceKm,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json["id"] ?? 0,
      businessName: json["business_name"] ?? "Unnamed Garage",
      // Safely convert numbers to double even if they are null or strings
      rating: double.tryParse(json["rating"]?.toString() ?? "0.0") ?? 0.0,
      distanceKm:
          double.tryParse(json["distance_km"]?.toString() ?? "0.0") ?? 0.0,
    );
  }
}
