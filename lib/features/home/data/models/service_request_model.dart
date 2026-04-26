class ServiceRequestModel {
  final int id;
  final int? providerId;
  final String? providerName;
  final String? providerPhone;
  final String status;
  final String? serviceType;
  final String? vehicleName;
  final String? description;
  final String? imageUrl;
  final String? address;
  final String? createdAt;

  // Review Data
  final int? rating;
  final String? reviewComment;
  final List<String>? reviewTags;

  const ServiceRequestModel({
    required this.id,
    this.providerId,
    this.providerName,
    this.providerPhone,
    required this.status,
    this.serviceType,
    this.vehicleName,
    this.description,
    this.imageUrl,
    this.address,
    this.createdAt,
    this.rating,
    this.reviewComment,
    this.reviewTags,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] as Map<String, dynamic>?;
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    final review = json['review'] as Map<String, dynamic>?;

    // Fix: Using 'name' from your logs
    String? pName = provider != null
        ? (provider['name'] ?? provider['business_name'])
        : (json['provider_name'] ?? json['business_name']);

    // Fix: Using 'phone_number' from your logs
    String? pPhone = provider != null
        ? (provider['phone_number'] ?? provider['phone'])
        : json['provider_phone'];

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
      id: json['id'] ?? json['request_id'] ?? 0,
      providerId: provider != null ? provider['id'] : json['provider_id'],
      providerName: pName ?? 'Garage',
      providerPhone: pPhone,
      status: json['status'] ?? 'PENDING',
      serviceType: json['service_type'] is Map
          ? json['service_type']['name']
          : json['service_type'],
      vehicleName: vName ?? json['vehicle_name'],
      description: json['description'] ?? json['issue_description'],
      imageUrl: json['photo_url'] ?? json['photo'] ?? json['image_url'],
      address: json['incident_address'] ?? json['address'],
      createdAt: json['created_at'],

      // Parsing Review
      rating: _toInt(review != null ? review['rating'] : json['rating']),
      reviewComment: review != null ? review['comment'] : json['comment'],
      reviewTags: review != null
          ? (review['tags'] as List?)?.cast<String>()
          : null,
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  bool get isActive => [
    'PENDING',
    'ACCEPTED',
    'EN_ROUTE',
    'ON_THE_WAY',
    'ARRIVED',
    'IN_PROGRESS',
  ].contains(status.toUpperCase());
}
