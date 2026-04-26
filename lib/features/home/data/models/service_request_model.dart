import 'cart_item_model.dart';

class ServiceRequestModel {
  final int id;
  final int? providerId;
  final String? providerName;
  final String? providerPhone;
  final String status;
  final String? serviceType;
  final String? vehicleName;
  final String? description;
  final String? address;
  final String? createdAt;
  final List<CartItemModel> spareParts; // NEW: Added this field

  const ServiceRequestModel({
    required this.id,
    this.providerId,
    this.providerName,
    this.providerPhone,
    required this.status,
    this.serviceType,
    this.vehicleName,
    this.description,
    this.address,
    this.createdAt,
    this.spareParts = const [], // NEW
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] as Map<String, dynamic>?;

    // Parse spare parts from backend response
    var partsList = <CartItemModel>[];
    if (json['spare_parts'] != null && json['spare_parts'] is List) {
      partsList = (json['spare_parts'] as List)
          .map(
            (p) => CartItemModel(
              id: p['id'] ?? 0,
              name: p['name'] ?? 'Part',
              price: double.tryParse(p['price'].toString()) ?? 0,
              garageId: json['provider_id'] ?? 0,
              quantity: p['quantity'] ?? 1,
            ),
          )
          .toList();
    }

    return ServiceRequestModel(
      id: json['id'] ?? json['request_id'] ?? 0,
      providerId: json['provider_id'],
      providerName:
          provider?['business_name'] ?? json['provider_name'] ?? 'Garage',
      providerPhone: provider?['phone_number'],
      status: json['status'] ?? 'PENDING',
      serviceType: json['service_type'] is Map
          ? json['service_type']['name']
          : json['service_type'],
      vehicleName: json['vehicle_name'],
      description: json['description'] ?? json['issue_description'],
      address: json['address'],
      createdAt: json['created_at'],
      spareParts: partsList, // NEW
    );
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
