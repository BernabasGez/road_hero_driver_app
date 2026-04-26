class ProviderModel {
  final int id;
  final String businessName;
  final double? rating;
  final int? reviewCount;
  final bool isOnline;
  final double? distanceKm;
  final double? latitude;
  final double? longitude;
  final List<String> serviceTypes;
  final String? phone;

  const ProviderModel({
    required this.id,
    required this.businessName,
    this.rating,
    this.reviewCount,
    this.isOnline = false,
    this.distanceKm,
    this.latitude,
    this.longitude,
    this.serviceTypes = const [],
    this.phone,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    return ProviderModel(
      id: json['provider_id'] ?? json['id'] ?? 0,
      businessName: json['business_name'] ?? json['name'] ?? 'Garage',
      rating: _d(json['rating'] ?? json['rating_avg']),
      reviewCount: json['review_count'] ?? 0,
      isOnline: json['is_online'] == true,
      distanceKm: _d(json['distance_km']),
      latitude: _d(loc?['lat'] ?? json['lat']),
      longitude: _d(loc?['lng'] ?? json['lng']),
      phone: json['phone'],
      serviceTypes: (json['services'] as List?)?.cast<String>() ?? [],
    );
  }

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
