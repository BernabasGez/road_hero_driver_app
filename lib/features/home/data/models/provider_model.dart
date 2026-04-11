class ProviderModel {
  final int id;
  final String businessName;
  final double rating;
  final double distanceKm;
  final List<String> services;

  ProviderModel({
    required this.id,
    required this.businessName,
    required this.rating,
    required this.distanceKm,
    required this.services,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      // Matching 'provider_id' from your log
      id: json['provider_id'] ?? 0,
      businessName: json['business_name'] ?? json['name'] ?? 'Unknown Garage',
      rating: double.tryParse(json['rating']?.toString() ?? "0.0") ?? 0.0,
      distanceKm:
          double.tryParse(json['distance_km']?.toString() ?? "0.0") ?? 0.0,
      services: List<String>.from(json['services'] ?? []),
    );
  }
}
