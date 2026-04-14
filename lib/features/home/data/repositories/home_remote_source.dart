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

  // 1. CREATE EMERGENCY REQUEST: Solves "Enter a valid URL"
  Future<int> createRequest({
    required int providerId,
    required int vehicleId,
    required String issueDescription,
    required double lat,
    required double lng,
    String? imageUrl,
  }) async {
    final token = await LocalStorage.getToken();

    // The server is checking if this looks like a real URL (starting with https)
    final String safeImageUrl = (imageUrl == null || imageUrl.isEmpty)
        ? "https://roadhero.com/placeholder.jpg"
        : imageUrl;

    try {
      final response = await dio.post(
        'requests/',
        data: {
          "provider_id": providerId,
          "service_type_id": 1,
          "vehicle_id": vehicleId,
          "description": issueDescription.isEmpty
              ? "Emergency Assistance"
              : issueDescription,
          "is_scheduled": false,
          // Nested location object as seen in your Postman screenshot
          "location": {"lat": lat, "lng": lng, "address": "Bole, Addis Ababa"},
          // Fixed: Sending a fake URL instead of "none" to satisfy server validation
          "photo_url": safeImageUrl,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final dynamic resData = response.data['data'];
      return resData['id'] ?? resData['request_id'] ?? 0;
    } on DioException catch (e) {
      print("FINAL ERROR LOG: ${e.response?.data}");
      throw Exception(e.response?.data.toString() ?? "Validation failed");
    }
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

  Future<List<ProviderModel>> getNearbyProviders() async {
    final token = await LocalStorage.getToken();
    try {
      final response = await dio.get(
        'providers/nearby',
        queryParameters: {'lat': 9.0192, 'lng': 38.7525, 'radius_km': 100},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final List data = response.data['data']['results'] ?? [];
      return data.map((json) => ProviderModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getMyRequests() async {
    final token = await LocalStorage.getToken();
    try {
      final response = await dio.get(
        'requests/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'] ?? [];
    } catch (e) {
      return [];
    }
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
}
