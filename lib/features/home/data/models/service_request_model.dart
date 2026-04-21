class ServiceRequestModel {
  final int id;
  final int? providerId;
  final String? providerName;
  final String? providerPhone;
  final int? vehicleId;
  final String? vehicleName;
  final String? description;
  final String status;
  final String? serviceType;
  final bool isScheduled;
  final String? scheduledTime;
  final String? imageUrl;
  final double? lat;
  final double? lng;
  final String? address;
  final String? createdAt;

  // Tracking specific fields
  final double? providerLat;
  final double? providerLng;
  final String? eta;

  const ServiceRequestModel({
    required this.id,
    this.providerId,
    this.providerName,
    this.providerPhone,
    this.vehicleId,
    this.vehicleName,
    this.description,
    this.status = 'PENDING',
    this.serviceType,
    this.isScheduled = false,
    this.scheduledTime,
    this.imageUrl,
    this.lat,
    this.lng,
    this.address,
    this.createdAt,
    this.providerLat,
    this.providerLng,
    this.eta,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    // Extract nested objects if they exist
    final provider = json['provider'] as Map<String, dynamic>?;
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    final location = json['location'] as Map<String, dynamic>?;

    // Build Vehicle Name safely
    String? vName;
    if (vehicle != null) {
      final make = vehicle['make'] is Map
          ? vehicle['make']['name']
          : vehicle['make'];
      final model = vehicle['model'] is Map
          ? vehicle['model']['name']
          : vehicle['model'];
      vName = '${make ?? ""} ${model ?? ""}'.trim();
    }

    return ServiceRequestModel(
      // The backend uses 'id' for details and 'request_id' for creation success
      id: json['id'] ?? json['request_id'] ?? 0,

      // Provider Info (Handling nested object from detail view)
      providerId: provider != null ? provider['id'] : json['provider_id'],
      // Prioritize Business Name to avoid showing individual owner names
      providerName: provider != null
          ? (provider['business_name'] ?? provider['name'])
          : (json['business_name'] ??
                json['provider_name'] ??
                json['provider_business_name']),
      providerPhone: provider != null
          ? provider['phone']
          : json['provider_phone'],

      // Vehicle Info
      vehicleId: json['vehicle_id'],
      vehicleName: vName ?? json['vehicle_name'],

      description: json['description'] ?? json['issue_description'],
      status: json['status'] ?? 'PENDING',

      // Service Type can be a String or a Map with a 'name'
      serviceType: json['service_type'] is Map
          ? json['service_type']['name']
          : (json['service_type'] ?? json['service_type_name']),

      isScheduled: json['is_scheduled'] == true,
      scheduledTime: json['scheduled_time'],
      imageUrl: json['photo'] ?? json['image_url'],

      // Location Info (Checks nested object first)
      lat: _d(location != null ? location['lat'] : json['lat']),
      lng: _d(location != null ? location['lng'] : json['lng']),
      address: location != null
          ? location['address']
          : (json['address'] ?? json['incident_address']),

      createdAt: json['created_at'],

      // Tracking Data (Matches the /tracking endpoint)
      providerLat: _d(json['provider_lat']),
      providerLng: _d(json['provider_lng']),
      eta: json['eta_minutes'] != null
          ? "${json['eta_minutes']} mins"
          : json['eta']?.toString(),
    );
  }

  // Logic helpers for the UI
  bool get canCancel => status.toUpperCase() == 'PENDING';

  bool get isActive => [
    'PENDING',
    'ACCEPTED',
    'EN_ROUTE',
    'ON_THE_WAY',
    'ARRIVED',
    'IN_PROGRESS',
  ].contains(status.toUpperCase());

  // Safe parsing helper for numbers (handles int, double, and String)
  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
