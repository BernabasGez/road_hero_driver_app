class ProviderModel {
  final int id;
  final String businessName;
  final String? ownerName;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String? address;
  final double? rating;
  final int? reviewCount;
  final bool isOnline;
  final double? distanceKm;
  final String? logo;
  final List<String> serviceTypes;

  const ProviderModel({
    required this.id,
    required this.businessName,
    this.ownerName,
    this.phone,
    this.latitude,
    this.longitude,
    this.address,
    this.rating,
    this.reviewCount,
    this.isOnline = false,
    this.distanceKm,
    this.logo,
    this.serviceTypes = const [],
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    // 1. Get the nested location map
    final locationMap = json['location'] as Map<String, dynamic>?;

    return ProviderModel(
      // 2. Map ID and Name
      id: json['provider_id'] ?? json['id'] ?? 0,
      businessName: json['business_name'] ?? json['name'] ?? 'Garage',

      // 3. Map Nested Location
      latitude: _parseDouble(locationMap?['lat']),
      longitude: _parseDouble(locationMap?['lng']),

      // 4. Map the rest
      isOnline: json['is_online'] == true,
      rating: _parseDouble(json['rating']),
      reviewCount: json['review_count'] ?? 0,
      distanceKm: _parseDouble(json['distance_km']),

      // 5. Map services (Ensure this matches the string list in your JSON)
      serviceTypes: (json['services'] as List?)?.cast<String>() ?? [],
    );
  }
  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
