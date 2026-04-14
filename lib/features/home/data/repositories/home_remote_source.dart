import 'package:dio/dio.dart';
import 'package:road_hero/core/utils/local_storage.dart';
import 'package:road_hero/features/auth/data/models/user_model.dart';
import 'package:road_hero/features/home/data/models/provider_model.dart';

class HomeRemoteSource {
  final Dio dio;
  HomeRemoteSource(this.dio);

  Future<UserModel> getProfile() async {
    final token = await LocalStorage.getToken();
    final response = await dio.get(
      'users/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserModel.fromJson(response.data['data']);
  }

  // UPDATED: Now supports dynamic Radius, Online status, and Service IDs
  Future<List<ProviderModel>> getNearbyProviders({
    required double lat,
    required double lng,
    required double radius, // Added dynamic radius
    bool? isOnline,
    int? serviceTypeId,
  }) async {
    final token = await LocalStorage.getToken();
    try {
      final Map<String, dynamic> queryParams = {
        'lat': lat,
        'lng': lng,
        'radius_km': radius,
      };

      if (isOnline != null) queryParams['is_online'] = isOnline;
      if (serviceTypeId != null) queryParams['service_type_id'] = serviceTypeId;

      final response = await dio.get(
        'providers/nearby',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final dynamic rawResults = response.data['data']['results'];
      if (rawResults is List)
        return rawResults.map((json) => ProviderModel.fromJson(json)).toList();
      return [];
    } catch (e) {
      print("FILTERED SEARCH ERROR: $e");
      return [];
    }
  }

  Future<int> createRequest({
    required int providerId,
    required int vehicleId,
    required String issueDescription,
    required double lat,
    required double lng,
    String? imageUrl,
  }) async {
    final token = await LocalStorage.getToken();
    final String safeUrl = (imageUrl == null || imageUrl.isEmpty)
        ? "https://roadhero.com/placeholder.jpg"
        : imageUrl;
    try {
      final response = await dio.post(
        'requests/',
        data: {
          "provider_id": providerId,
          "service_type_id": 1,
          "vehicle_id": vehicleId,
          "is_scheduled": false,
          "location": {"lat": lat, "lng": lng, "address": "Current Location"},
          "description": issueDescription,
          "photo_url": safeUrl,
          "voice_note_url": "",
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final dynamic data = response.data['data'];
      return data['id'] ?? data['request_id'] ?? 0;
    } catch (e) {
      throw Exception("Failed to send request");
    }
  }

  Future<List<dynamic>> getMyRequests() async {
    final token = await LocalStorage.getToken();
    final response = await dio.get(
      'requests/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> getRequestDetail(int requestId) async {
    final token = await LocalStorage.getToken();
    final response = await dio.get(
      'requests/$requestId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getLiveTracking(int requestId) async {
    final token = await LocalStorage.getToken();
    try {
      final response = await dio.get(
        'requests/$requestId/tracking',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'];
    } catch (e) {
      return {"status": "PENDING", "eta_minutes": 0};
    }
  }

  Future<Map<String, dynamic>> diagnoseIssue(String description) async {
    final token = await LocalStorage.getToken();
    final response = await dio.post(
      'ai/diagnose',
      data: {"issue_description": description},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getUploadUrl(String fileName) async {
    final token = await LocalStorage.getToken();
    final response = await dio.post(
      'utils/upload-url',
      data: {"file_name": fileName, "content_type": "image/jpeg"},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data['data'];
  }
}
