class ProviderModel {
  final int id;
  final String businessName;
  final String phoneNumber;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final bool isOnline;
  final bool isVerified;
  final List<String> services;
  final String address;
  final double lat;
  final double lng;

  ProviderModel({
    required this.id,
    required this.businessName,
    required this.phoneNumber,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.isOnline,
    required this.isVerified,
    required this.services,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['provider_id'] ?? 0,
      businessName: json['business_name'] ?? json['name'] ?? 'Unknown Garage',
      phoneNumber: json['phone_number'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? "0.0") ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      distanceKm:
          double.tryParse(json['distance_km']?.toString() ?? "0.0") ?? 0.0,
      isOnline: json['is_online'] ?? false,
      isVerified: json['is_verified'] ?? false,
      services: List<String>.from(json['services'] ?? []),
      address: json['address'] ?? 'Addis Ababa',
      lat:
          double.tryParse(json['location']?['lat']?.toString() ?? "0.0") ?? 0.0,
      lng:
          double.tryParse(json['location']?['lng']?.toString() ?? "0.0") ?? 0.0,
    );
  }
}
